// controllers/logincontroller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../infrastructure/routes/admin_routes.dart';

class LoginController extends GetxController {
  final enrollmentController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var hidePassword = true.obs;

  Future<void> login() async {
    final enrollment = enrollmentController.text.trim();
    final password = passwordController.text.trim();

    if (enrollment.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // simulate API

    if (enrollment == '0') {
      Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
      Get.snackbar(
        'Success',
        'Login Successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:  Color(0xFFEB8A2A),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Invalid Credentials',
        'Please check your enrollment and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    enrollmentController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
