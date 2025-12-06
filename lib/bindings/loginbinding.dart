// bindings/loginbinding.dart
import 'package:get/get.dart';
import 'package:gold_app/controllers/logincontroller.dart';
import '../controllers/MainScreenController.dart';

class Loginbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
