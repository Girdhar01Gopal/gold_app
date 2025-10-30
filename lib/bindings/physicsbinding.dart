// bindings/physicsbinding.dart
import 'package:get/get.dart';
import 'package:gold_app/controllers/mathscreencontroller.dart';
import 'package:gold_app/controllers/physicscontroller.dart';
import '../controllers/MainScreenController.dart';

class Physicsbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Physicscontroller>(() => Physicscontroller());
  }
}
