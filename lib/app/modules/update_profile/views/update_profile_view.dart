import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_profile_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  Map<String, dynamic> user = Get.arguments;
  UpdateProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.NoHpC.text = user["NoHp"];
    controller.namaC.text = user["nama"];
    controller.emailC.text = user["email"];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
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
              readOnly: true,
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
              readOnly: true,
              autocorrect: false,
              controller: controller.emailC,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              )),
          SizedBox(
            height: 30,
          ),
          Text(
            "Photo Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<UpdateProfileController>(
                builder: (c) {
                  if (c.image != null) {
                    return ClipOval(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(
                          File(c.image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (user["profile"] != null) {
                      return Column(
                        children: [
                          ClipOval(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                user["profile"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteProfile(user["uid"]);
                            },
                            child: Text("Delete"),
                          )
                        ],
                      );
                    } else {
                      return Text("No Image");
                    }
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  controller.pickImage();
                },
                child: Text("Choose"),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Obx(() {
            return ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.updateProfile(user["uid"]);
                    Get.snackbar("Berhasil", "Profile sudah terupdate");
                  }
                },
                child: Text(controller.isLoading.isFalse ? "Update Profile" : "Loading"));
          })
        ],
      ),
    );
  }
}
