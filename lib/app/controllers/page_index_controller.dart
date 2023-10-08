import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presensi/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    print('click index=$i');
    switch (i) {
      case 1:
        print("ABSENSI");
        Map<String, dynamic> dataResponse = await determinePosition();

        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];

          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          //convert latlong to address
          String address =
              "${placemarks[2].street},${placemarks[2].subLocality},${placemarks[2].locality},${placemarks[2].subAdministrativeArea}";
          ///////
          await updatePosition(position, address);
          // print(placemarks);

          //distance
          double distance = Geolocator.distanceBetween(-6.3540931, 106.8389984, position.latitude, position.longitude);

          //presence
          await presensi(position, address, distance);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;

      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;

      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

//presence function
  Future<void> presensi(Position position, String address, double distance) async {
    String uid = await auth.currentUser!.uid;
    //
    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("participant").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();
//....
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
//....

    String status = "Di Luar Area";

    if (distance <= 100) {
      //di dalam area
      status = "Di Dalam Area";
    }

    if (snapPresence.docs.length == 0) {
      //belum pernah set absen

      await Get.defaultDialog(
          title: "Validasi",
          middleText: "Apakah kamu yakin akan mengisi daftar hadir (MASUK) ?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await colPresence.doc(todayDocID).set({
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "address": address,
                    "status": status,
                    "distance": distance,
                  }
                });
                Get.back();
                Get.snackbar("Berhasil", "Kamu telah mengisi daftar hadir");
              },
              child: Text("Yes"),
            )
          ]);
    } else {
      //udah pernah absen
      DocumentSnapshot<Map<String, dynamic>> todayDoc = await colPresence.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        //tinggal absen keluar  / udah 22 nya
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();

        if (dataPresenceToday?["keluar"] != null) {
          //udah absen masuk & keluar
          Get.snackbar("Berhasil", "sudah absen, tidak dapat absen kembali");
        } else {
          //absen keluar
          await Get.defaultDialog(
              title: "Validasi",
              middleText: "Apakah kamu yakin akan mengisi daftar (KELUAR) ?",
              actions: [
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await colPresence.doc(todayDocID).update({
                      "keluar": {
                        "date": now.toIso8601String(),
                        "lat": position.latitude,
                        "long": position.longitude,
                        "address": address,
                        "status": status,
                        "distance": distance,
                      }
                    });
                    Get.back();
                    Get.snackbar("Berhasil", "Kamu telah mengisi daftar (KELUAR)");
                  },
                  child: Text("Yes"),
                )
              ]);
        }
      } else {
        //absen masuk
        await Get.defaultDialog(
            title: "Validasi",
            middleText: "Apakah kamu yakin akan mengisi daftar hadir (MASUK) ?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).set({
                    "date": now.toIso8601String(),
                    "masuk": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    }
                  });
                  Get.back();
                  Get.snackbar("Berhasil", "Kamu telah mengisi daftar hadir");
                },
                child: Text("Yes"),
              )
            ]);
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection("participant").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
  }

//geolocator
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        "message": "Tidak dapat mengakses GPS dari device ini.",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          "message": "Izin aktifasi GPS ditolak.",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message": "Buka setting dan izinkan aktifasi GPS.",
        "error": true,
      };
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    //control mapingg
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device.",
      "error": false,
    };
  }

//////////////////////////////////////////////
}
