import 'package:get/get.dart';
import 'package:gold_app/controllers/examinstructioncontroller.dart';
import '../controllers/dashboard_controller.dart';

class Examinstructionbinding extends Bindings {
  @override
  void dependencies() {
    // Initialize HomeController when the screen is loaded
    Get.lazyPut<examinstructioncontroller>(() => examinstructioncontroller());
  }
}
