// screens/admin_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_splash_controller.dart';

class AdminSplashScreen extends GetView<AdminSplashController> {
  const AdminSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller (if not already)
    final AdminSplashController controller = Get.put(AdminSplashController());

    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: SafeArea(
        child: Stack(
          children: [
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FIITJEE Logo Text
                  Text(
                    'MGEPL',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subheading Text
                  const Text(
                    'ASSIGNMENT AND PACKAGE',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 4,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Version text (reactive)
                  Obx(() => Text(
                        "Version ${controller.version.value}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      )),
                ],
              ),
            ),

            // Clear data and cache button
            // Positioned(
            //   bottom: 20,
            //   left: 20,
            //   child: TextButton(
            //     onPressed: controller.clearDataAndCache,
            //     style: TextButton.styleFrom(
            //       foregroundColor: Colors.grey[700],
            //       textStyle: const TextStyle(fontSize: 12),
            //     ),
            //     child: const Text('Clear data and cache'),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
