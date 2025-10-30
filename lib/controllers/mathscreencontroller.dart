// controllers/mathscreencontroller.dart
import 'package:get/get.dart';

class Mathscreencontroller extends GetxController {
  // Use .obs to make variables reactive
  RxString currentGPA = '0.14'.obs;
  final RxString selectedPhase = 'PHASE I'.obs;
final List<String> phases = ['PHASE I', 'PHASE II', 'PHASE III', 'PHASE IV'];


  // Method to update GPA (you can modify this as per your logic)
  void updateGPA(String newGPA) {
    currentGPA.value = newGPA;
  }
}
