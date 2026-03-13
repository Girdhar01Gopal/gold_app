// bindings/physicsbinding.dart
import 'package:get/get.dart';

import 'package:gold_app/controllers/physicscontroller.dart';
import 'package:gold_app/controllers/resultcontroller.dart';
class Resultbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(() => ResultController());
  }
}
