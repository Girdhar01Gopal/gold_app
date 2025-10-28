import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize HomeController when the screen is loaded
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
