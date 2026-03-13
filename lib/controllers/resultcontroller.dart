import 'dart:convert';
import 'package:get/get.dart';
import 'package:gold_app/Model/resultmodel.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as http;
import 'package:gold_app/appurl/adminurl.dart';

class ResultController extends GetxController {
  var schoolId = ''.obs;
  final studentId = ''.obs;
  var questionTestId = ''.obs;
  var testId = ''.obs;
  var assignmentTopicId = ''.obs;
  var assignmentChapterId = ''.obs;
  var name = ''.obs;


  final isLoading = false.obs;
  final error = ''.obs;

  final resultModel = Rxn<ResultModel>();


@override  void onInit() async{
    super.onInit();
     schoolId.value = await PrefManager().readValue(key: PrefConst.SchoolId) ?? '';
    studentId.value = await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
    name.value = await PrefManager().readValue(key: PrefConst.studentname) ?? '';
      questionTestId.value = Get.arguments['questiontestid'] ?? '';
      testId.value = Get.arguments['testId'] ?? '';
      assignmentTopicId.value = Get.arguments['assignmenttopicid'] ?? '';
      assignmentChapterId.value = Get.arguments['assignmentchapterid'] ?? '';
    fetchResult();


    }

  Future<void> fetchResult() async {
    isLoading.value = true;
    error.value = '';

    try {
      final url = Uri.parse('${Adminurl.result}/${schoolId.value}/${studentId.value}/${questionTestId.value}/${testId.value}/${assignmentChapterId.value}/${assignmentTopicId.value}');
     print('Fetching result from URL: $url'); // Debug print
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        resultModel.value = ResultModel.fromJson(jsonMap);
      } else {
        error.value = 'HTTP ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      error.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
