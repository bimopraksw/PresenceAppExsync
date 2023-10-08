import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_participant_controller.dart';

class AddParticipantView extends GetView<AddParticipantController> {
  const AddParticipantView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
              autocorrect: false,
              controller: controller.namaC,
              decoration: InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              )),
          SizedBox(
            height: 20,
          ),
          TextField(
              autocorrect: false,
              controller: controller.NoHpC,
              decoration: InputDecoration(
                labelText: "No Handphone",
                border: OutlineInputBorder(),
              )),
          SizedBox(
            height: 20,
          ),
          TextField(
              autocorrect: false,
              controller: controller.emailC,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              )),
          SizedBox(
            height: 30,
          ),
          Obx(() {
            return ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.addparticipant();
                    Get.snackbar(
                        "Akun berhasil dibuat", "Silahkan Cek Email pada akun yang terdaftar untuk bisa Login");
                  }
                },
                child: Text(controller.isLoading.isFalse ? "Buat Akun" : "Loading"));
          })
        ],
      ),
    );
  }
}
