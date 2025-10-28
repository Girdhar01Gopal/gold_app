import 'package:get/get.dart';

class ContinueScreenController extends GetxController {
  // Use .obs to make variables reactive
  RxString currentGPA = '0.14'.obs;

  // Method to update GPA (you can modify this as per your logic)
  void updateGPA(String newGPA) {
    currentGPA.value = newGPA;
  }
}
