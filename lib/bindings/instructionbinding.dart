import 'package:get/get.dart';
import 'package:gold_app/controllers/instructioncontroller.dart';
import '../controllers/dashboard_controller.dart';

class Instructionbinding extends Bindings {
  @override
  void dependencies() {
    // Initialize HomeController when the screen is loaded
    Get.lazyPut<Instructioncontroller>(() => Instructioncontroller());
  }
}
