import 'package:get/get.dart';
import '../controllers/Loading_Controller.dart';

class LoadingBinding extends Bindings {
  @override
  void dependencies() {
    // Lazily put the controller so that it is available during screen loading
    Get.lazyPut<LoadingController>(() => LoadingController());
  }
}
