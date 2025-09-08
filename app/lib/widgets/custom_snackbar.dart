import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbars {
  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 10,
        left: 16,
        right: 16,
      ),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 10,
        left: 16,
        right: 16,
      ),
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 4),
    );
  }

  static void alert(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom + 10,
        left: 16,
        right: 16,
      ),
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
    );
  }
}