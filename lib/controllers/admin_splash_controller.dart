import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../infrastructure/routes/admin_routes.dart';

class AdminSplashController extends GetxController {
  final box = GetStorage(); // GetStorage instance

  // Observable version string
  final version = "1.9".obs;

  @override
  void onInit() {
    super.onInit();
    _navigateBasedOnLoginStatus();
  }

  // Function to check login status and navigate accordingly
  void _navigateBasedOnLoginStatus() async {
    await Future.delayed(const Duration(seconds: 5)); // Simulating splash screen delay

    bool isLoggedIn = box.read('isLoggedIn') ?? false; // Check login status from storage

    // Navigate to loading screen or login screen based on login status
    if (isLoggedIn) {
      Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
    } else {
      Get.offAllNamed(AdminRoutes.LOADING_SCREEN); // Change to LOGIN_SCREEN if not logged in
    }
  }

  // Clear data and cache method
  void clearDataAndCache() {
    // Here you can clear shared preferences, GetStorage, or any other data
    box.erase(); // Clears all data in GetStorage (you can add more custom clear logic if needed)
    debugPrint("Data and cache cleared");

    // Show a snackbar confirmation
    Get.snackbar("Success", "Data & Cache Cleared", snackPosition: SnackPosition.BOTTOM);
  }
}
