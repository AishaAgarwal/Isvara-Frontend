import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
class appController extends GetxController {
  Rx<bool> on = false.obs;
  Rx<bool> x = true.obs;
  Rx<bool> not = false.obs;
  Rx<bool> isTapped = false.obs;
  String? ani = 'Idle'.obs.value;
  String? tok = null.obs.value;
}
