import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/loginviewmodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as https;
import 'package:http/http.dart' as http;

import '../infrastructure/routes/admin_routes.dart';

class LoginController extends GetxController {
  final passwordController = TextEditingController();
//MG6052612610001
  var isLoading = false.obs;
  var hidePassword = true.obs;

Future<loginmodel> login({
  required String enrollmentNo,
}) async {
  isLoading.value = true;
  final url = Uri.parse(Adminurl.loginurl);

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'AdmissionNo': enrollmentNo,
      }),
    );

    if (response.statusCode == 200) {
      isLoading.value = false;
      final data = jsonDecode(response.body);
      print("✅ Login Response Data: $data");

      // Optional: check for message or extract data
      if (data['message'] == "Login succesfully" || data['message'] == "Login successfully") {
        Get.offAllNamed(AdminRoutes.homeScreen);
        PrefManager().writeValue(key: PrefConst.isLoggedIn, value: "yes");
        PrefManager().writeValue(
          key: PrefConst.EnrollmentNo,
          value: jsonEncode(data['data']?['AdmissionNo']),
        );
         PrefManager().writeValue(
          key: PrefConst.SchoolId,
          value: jsonEncode(data['data']?['SchoolId']),
        ); PrefManager().writeValue(
          key: PrefConst.StudentId,
          value: jsonEncode(data['data']?['StudentId']),
        ); PrefManager().writeValue(
          key: PrefConst.CourseId,
          value: jsonEncode(data['data']?['CourseId']),
        );
        PrefManager().writeValue(
          key: PrefConst.studentname,
          value: jsonEncode(data['data']?['StudentName']),
        );
        PrefManager().writeValue(
          key: PrefConst.session,
          value: jsonEncode(data['data']?['Session']),
        );
         PrefManager().writeValue(
          key: PrefConst.session,
          value: jsonEncode(data['data']?['Session']),
        );
         PrefManager().writeValue(
          key: PrefConst.className,
          value: jsonEncode(data['data']?['CourseName']),
        );
        print("✅ Login successful for EnrollmentNo: ${data['data']?['AdmissionNo'] ?? ''}");
        print("✅ Full Response Data: $data");
        print("✅ Stored EnrollmentNo: ${await PrefManager().readValue(key: PrefConst.EnrollmentNo)}");
        print("✅ Stored SchoolId: ${await PrefManager().readValue(key: PrefConst.SchoolId)}");
        print("✅ Stored StudentId: ${await PrefManager().readValue(key: PrefConst.StudentId)}");
        print("✅ Stored CourseId: ${await PrefManager().readValue(key: PrefConst.CourseId)}");
        print("✅ Stored StudentName: ${await PrefManager().readValue(key: PrefConst.studentname)}");
        print("✅ Stored Session: ${await PrefManager().readValue(key: PrefConst.session
)}");
        print("✅ Stored ClassName: ${await PrefManager().readValue(key: PrefConst.className)}");
        Get.snackbar(
          "Login Successful",
          "Welcome ${data['data']?['AdmissionNo'] ?? ''}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:  Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Login Failed",
          data['message'] ?? "Invalid credentials.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      isLoading.value = false;
      Get.snackbar(
        "Error ${response.statusCode}",
        "Invalid enrollment number or server issue.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return loginmodel.fromJson(jsonDecode(response.body));
  } catch (e) {
    isLoading.value = false;
    Get.snackbar(
      "Error",
      "Something went wrong. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return Future.error(e);
  }
}
  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
