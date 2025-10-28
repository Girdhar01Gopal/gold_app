import 'package:get/get.dart';
import '../controllers/ContinueScreenController.dart';

class ContinueScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContinueScreenController>(() => ContinueScreenController());
  }
}
