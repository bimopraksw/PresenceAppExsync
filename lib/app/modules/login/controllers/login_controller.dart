import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presensi/app/routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs; //loading controller
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    isLoading.value == true;
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(email: emailC.text, password: passC.text);
        print(userCredential);

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            isLoading.value == false;
            if (passC.text == "password") {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(title: "Kamu belum verifikasi email", middleText: "silahkan verifikasi email", actions: [
              OutlinedButton(
                  onPressed: () {
                    isLoading.value == false;
                    Get.back();
                  },
                  child: Text("Tutup")),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      Get.back();
                      Get.snackbar("Email verifikasi telah terkirim", "Silahkan cek Email");
                      isLoading.value == false;
                    } catch (e) {
                      isLoading.value == false;
                      Get.snackbar(
                          "Terjadi kesalahan", "Tidak dapat mengirim email verifikasi. Silahkan Hubungi Admin");
                    }
                  },
                  child: Text("Kirim Ulang "))
            ]); //back / close dialog
          }
        }
        isLoading.value == false;
      } on FirebaseAuthException catch (e) {
        isLoading.value == false;
        if (e.code == 'user-not-found') {
          Get.snackbar("Terjadi kesalahan", "Email tidak terdaftar!");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Terjadi kesalahan", "Password salah!");
        } else {
          Get.snackbar("Terjadi kesalahan", "Email & Password harus diisi!");
        }
      }
    }
  }
}
