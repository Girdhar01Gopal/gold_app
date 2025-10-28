import 'package:get/get.dart';

class UsageController extends GetxController {
  // You can add your variables and logic for managing usage here.
  var usageData = ''.obs;

  // Example function to simulate fetching or managing data
  void fetchUsageData() {
    // Simulate fetching data (could be from an API or local storage)
    usageData.value = 'Data fetched successfully.';
  }
}
