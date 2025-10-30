// bindings/mathscreenbinding.dart
import 'package:get/get.dart';
import 'package:gold_app/controllers/mathscreencontroller.dart';
import '../controllers/MainScreenController.dart';

class Mathscreenbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Mathscreencontroller>(() => Mathscreencontroller());
  }
}
