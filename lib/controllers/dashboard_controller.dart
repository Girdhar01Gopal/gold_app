import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gold_app/Model/subjectmodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as http;


class HomeController extends GetxController {
  TextEditingController testId = TextEditingController();
    TextEditingController passcode = TextEditingController();
    var enrollmentNo = ''.obs;
  var isLoading = false.obs;
          var hidePassword = true.obs;
          var studentname = ''.obs;
          var className = ''.obs;
          var session = ''.obs;
          var schoolid = ''.obs;
          var studentid = ''.obs; 

          var subjects = <dynamic>[].obs;

var isNavigating = false.obs;
var start = false.obs;

@override
  void onInit() async{
    // TODO: implement onInit
    
       enrollmentNo.value = await PrefManager().readValue(key: PrefConst.EnrollmentNo);
      studentname.value = await PrefManager().readValue(key: PrefConst.studentname);
      className.value = await PrefManager().readValue(key: PrefConst.className);
      session.value = await PrefManager().readValue(key: PrefConst.session);
      schoolid.value = await PrefManager().readValue(key: PrefConst.SchoolId);
      studentid.value = await PrefManager().readValue(key: PrefConst.StudentId);

   print("✅ EnrollmentNo in HomeController: ${enrollmentNo.value}");
    super.onInit();
    allsubject();
  }

Future<void> allsubject() async {
  try {
    final response = await http.get(Uri.parse("${Adminurl.allsubject}/${schoolid.value}/${studentid.value}"));
    print(response);
     print("✅ allsubject Response: ${response.body}");
    
    if (response.statusCode == 200) {
      final subjectModel = subjectmodel.fromJson(jsonDecode(response.body));
      if (subjectModel.data != null && subjectModel.data!.isNotEmpty) {
      subjects.value = subjectModel.data!;  // Update the controller's subjects
      }
    } else {
      throw Exception('Failed to load subjects');
    }
  } catch (e) {
    print("Error in allsubject: $e");
  }
}

void voidtest() async {
  // Check if Test ID or Passcode is empty
  if (testId.text.isEmpty || passcode.text.isEmpty) {
    Get.snackbar(
      "Missing Fields",
      "Please enter both Test ID and Passcode",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
    return;
  }

  // Check connectivity before proceeding
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.ethernet) {
    // Show alert if no internet connection
  
    // Simulate some processing (e.g., API call) with a delay
  await Future.delayed(const Duration(seconds: 1)); // Simulated delay

  // Dismiss the loader after the delay
 

  // // Proceed to test screen after verification
  // Get.offAllNamed(
  //   AdminRoutes.instruction,
  //   arguments: {
  //     'testId': testId.text,
  //     'passcode': passcode.text,
  //   },
  // ); // Exit the function if no internet
  }
    Get.snackbar(
      "No Internet Connection",
      "Please check your internet connection and try again",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  

  // Show loader


  
}

  void goToMainScreen() async {
    isNavigating.value = true; // Show loader
    await Future.delayed(const Duration(seconds: 1)); // Simulated delay
    Get.toNamed(AdminRoutes.MAIN_SCREEN)?.then((_) {
      // when returning back
      isNavigating.value = false; // revert icon
    });
  }
  void onDownloadPressed() {
    if (testId.text.isEmpty || passcode.text.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please enter both Test ID and Passcode",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
 
    // ✅ Simulated success (replace with your actual download logic)
   

    print("✅ Download triggered | Test ID: ${testId.text}, Passcode: ${passcode.text}");
  }
}
