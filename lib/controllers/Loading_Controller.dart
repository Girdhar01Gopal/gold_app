import 'package:get/get.dart';
import '../infrastructure/routes/admin_routes.dart';

class LoadingController extends GetxController {
  // Logic for the loading screen
  @override
  void onInit() {
    super.onInit();
    // Navigate to the Home screen after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      // Using the correct route defined in AdminRoutes
      Get.offNamed(AdminRoutes.homeScreen);  // Navigate to the /home route
    });
  }
}
