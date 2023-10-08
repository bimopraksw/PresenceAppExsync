import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as s;

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController NoHpC = TextEditingController();
  TextEditingController namaC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  s.FirebaseStorage storage = s.FirebaseStorage.instance;

  final ImagePicker picker = ImagePicker();

  XFile? image;

  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   print(image!.name);
    //   print(image!.name.split(".").last); // pick extension
    //   print(image!.path);
    // } else {
    //   print(image);
    // }
    update();
  }

  Future<void> updateProfile(String uid) async {
    if (NoHpC.text.isNotEmpty && namaC.text.isNotEmpty && emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "nama": namaC.text,
        };
        if (image != null) {
          //upload image ke firebase storage
          File file = File(image!.path);
          String ext = image!.name.split(".").last;

          await storage.ref('$uid/profile.$ext').putFile(file);
          String urlImage = await storage.ref('$uid/profile.$ext').getDownloadURL();

          data.addAll({"profile": urlImage});
        }
        await firestore.collection("participant").doc(uid).update(data);
        image = null;
      } catch (e) {
        Get.snackbar("Terjadi kesalahan", "Tidak dapat melakukan request");
      } finally {
        isLoading.value = false;
        Get.back();
      }
    }
  }

  void deleteProfile(String uid) async {
    try {
      await firestore.collection("participant").doc(uid).update({
        "profile": FieldValue.delete(),
      });
      Get.back();
      Get.snackbar("Berhasil delete profile picture", ".......");
    } catch (e) {
      Get.snackbar("Terjadi kesalahan", "Tidak dapat melakukan request");
    } finally {
      update();
      Get.back();
    }
  }
}
