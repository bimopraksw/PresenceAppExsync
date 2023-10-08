import 'package:get/get.dart';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddParticipantController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddParticipant = false.obs;
  TextEditingController namaC = TextEditingController();
  TextEditingController NoHpC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddParticipant() async {
    if (passAdminC.text.isNotEmpty) {
      isLoadingAddParticipant.value = true;
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential participantCredential =
            await auth.createUserWithEmailAndPassword(email: emailC.text, password: "password");

        if (participantCredential.user != null) {
          String uid = participantCredential.user!.uid;

          await firestore.collection("participant").doc(uid).set({
            "nama": namaC.text,
            "NoHp": NoHpC.text,
            "email": emailC.text,
            "uid": uid,
            "role": "Pegawai",
            "created at": DateTime.now().toIso8601String(),
            //firebase gabisa nyimpen tipedata datetime jadi convert to iso string
          });
          await participantCredential.user!.sendEmailVerification(); //send email verif

          await auth.signOut(); //sign out after add participant

          UserCredential userCredentialAdmin = await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          ); //login admin lagi

          Get.back(); //close dialog
          // Get.back();//back home
          Get.snackbar("Berhasil", "Berhasil menambahkan akun");
        }
      } on FirebaseAuthException catch (e) {
        isLoadingAddParticipant.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar("Terjadi kesalahan", "Password terlalu lemah");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi kesalahan", "Email telah terpakai");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Terjadi kesalahan", "Password salah");
        } else {
          Get.snackbar("Terjadi kesalahan", "${e.code}");
        }
      } catch (e) {
        isLoadingAddParticipant.value = false;
        Get.snackbar("Terjadi kesalahan", "error saat menambahkan");
      }
    } else {
      isLoading.value = false;
      Get.snackbar("Error", "Password Admin wajib diisi");
    }
  }

  Future<void> addparticipant() async {
    if (namaC.text.isNotEmpty && NoHpC.text.isNotEmpty && emailC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
          title: "Validasi Admin",
          content: Column(
            children: [
              Text("Masukan Password Admin"),
              SizedBox(height: 10),
              TextField(
                controller: passAdminC,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                isLoading.value = false;
                Get.back();
              },
              child: Text("Cancel"),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: () async {
                  if (isLoadingAddParticipant.isFalse) {
                    await prosesAddParticipant();
                  }
                  isLoading.value = false;
                },
                child: Text(isLoadingAddParticipant.isFalse ? "Tambah akun" : "Loading..."),
              );
            })
          ]);
    } else {
      Get.snackbar("Terjadi kesalahan", "Mohon isi data dengan lengkap");
    }
  }
}
