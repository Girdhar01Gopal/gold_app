import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gold_app/Model/instructionmodel.dart' show Data;
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:http/http.dart' as https;

class examinstructioncontroller extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Data> instructions = <Data>[].obs;
  
  RxString courseId = ''.obs;
  RxString schoolId = ''.obs;
  RxString studentid = ''.obs;
  RxString testId = ''.obs;
  RxString passcode = ''.obs;
  RxString batchid = ''.obs;
  RxString assigtTopicId = ''.obs;
  RxString assigtChapterId = ''.obs;
  RxString subjectId = ''.obs;
  RxString assExamRound = ''.obs;
  var testid = "".obs;


  @override
  void onInit() async {
    super.onInit();
    
    // Fetch values from storage and set them reactively
    courseId.value   = await PrefManager().readValue(key: PrefConst.CourseId) ?? '';
    schoolId.value   = await PrefManager().readValue(key: PrefConst.SchoolId) ?? '';
    studentid.value  = await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
    batchid.value  = await PrefManager().readValue(key: PrefConst.batchiid) ?? '';

    testId.value          = Get.arguments['testId'] ?? '';
    passcode.value        = Get.arguments['passcode'] ?? '';
    testid.value          = Get.arguments['type'] ?? '';
    assigtTopicId.value   = Get.arguments['AssigtTopicId']?.toString() ?? '';
    assigtChapterId.value = Get.arguments['AssigtChapterId']?.toString() ?? '';
    subjectId.value       = Get.arguments['SubjectId']?.toString() ?? '';
    assExamRound.value    = Get.arguments['AssExamRound']?.toString() ?? '';
    fetchInstructions();
   
  }

  // Function to fetch the instructions
  Future<void> fetchInstructions() async {
    try {
      isLoading.value = true;
      
      final headers = {
        'Content-Type': 'application/json',
       
      };

      final url = "${Adminurl.instructionUrl}/${schoolId.value}/${courseId.value}/${testId.value}/${batchid.value}";
      print("Fetching instructions from URL: $url");
      var response = await https.get(Uri.parse(url), headers: headers);

    
    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      var jsonData = jsonDecode(decodedBody);
      
      // Extract data list from JSON response
      List<dynamic> dataList = jsonData['data'] ?? [];
      instructions.value = dataList.map((item) => Data.fromJson(item)).toList();
      } else {
        Get.snackbar(
          "Error",
          "Failed to load instructions, please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // voidtest function for validation and navigation
  void voidtest() async {
    if (testId.value.isEmpty || passcode.value.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please enter both Test ID and Passcode",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Check Connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Get.snackbar(
        "No Internet Connection",
        "Please check your internet connection and try again",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // OPTIONAL: loader dialog while verifying passcode
     Get.dialog(
    Center(
      child: LoadingAnimationWidget.newtonCradle(
        color: Color(0xFF8B2D28),
        size: 80.h,
      ),
    ),
    barrierDismissible: false,
  );

    // Simulated delay (replace with your API call to verify passcode)
    await Future.delayed(const Duration(seconds: 1));

    Get.back(); // remove loader

    // SUCCESS → GO TO TEST SCREEN
    Get.offAllNamed(
      AdminRoutes.testscreen,
      arguments: {
        'testId': testId.value,
        'passcode': passcode.value,
        'AssigtTopicId': assigtTopicId.value,
        'AssigtChapterId': assigtChapterId.value,
        'SubjectId': subjectId.value,
        'AssExamRound': assExamRound.value,
      },
    );
          print("Navigating to Test Screen with args: testId=${testId.value}, passcode=${passcode.value}, AssigtTopicId=${assigtTopicId.value}, AssigtChapterId=${assigtChapterId.value}, SubjectId=${subjectId.value}, AssExamRound=${assExamRound.value}");

  }
}
