// bindings/testscreenbinding.dart
import 'package:get/get.dart';
import 'package:gold_app/controllers/testscreencontroller.dart';
import '../controllers/MainScreenController.dart';

class Testscreenbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Testscreencontroller>(() => Testscreencontroller());
  }
}
