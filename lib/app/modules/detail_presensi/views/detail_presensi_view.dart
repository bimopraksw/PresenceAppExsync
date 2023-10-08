import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Presensi'),
          backgroundColor: Colors.blue[700],
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "${DateFormat.yMMMMEEEEd().format(DateTime.parse(data['date']))}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Jam :${DateFormat.jms().format(DateTime.parse(data['masuk']!['date']))}"),

                  Text("Posisi : ${data['masuk']!['lat']}, ${data['masuk']!['long']}"),
                  Text("Status : ${data['masuk']!['status']}"),
                  Text("Address : ${data['masuk']!['address']}"),
                  Text("Jarak : +- ${data['masuk']!['distance'].toString().split(".").first} Meter"),

                  ///////////////////////////////////////////

                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Keluar",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(data['keluar']?['date'] == null
                      ? "Jam : -"
                      : "Jam :${DateFormat.jms().format(DateTime.parse(data['keluar']!['date']))}"),
                  ///////////////////////////////////////////
                  Text(data['keluar']?['lat'] == null && data['keluar']?['long'] == null
                      ? "Posisi : -"
                      : "Posisi : ${data['keluar']!['lat']}, ${data['keluar']!['long']}"),
                  Text(data['keluar']?['status'] == null ? "Status : -" : "Status : ${data['keluar']!['status']}"),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
              ),
            ),
          ],
        ));
  }
}
