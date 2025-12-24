import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:gold_app/appurl/adminurl.dart';

/// Global Connectivity Service that persists across all screens
/// This service monitors internet connectivity and automatically uploads
/// pending answers whenever connection is available
class ConnectivityService extends GetxService {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  var isOnline = true.obs;
  var isUploading = false.obs;

  // Test IDs and student info for current test
  String? _currentTestId;
  String? _schoolId;
  String? _studentId;
  String? _studentidd;
  String? _questionTestId;
  String? _assignmentChapterId;
  String? _assignmentTopicId;

  // Track uploaded questions globally
  final uploadedQuestions = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _startConnectivityMonitoring();
  }

  /// Initialize test context - call this when test starts
  void initializeTestContext({
    required String testId,
    required String schoolId,
    required String studentId,
    required String studentidd,
    required String questionTestId,
    String? assignmentChapterId,
    String? assignmentTopicId,
  }) {
    _currentTestId = testId;
    _schoolId = schoolId;
    _studentId = studentId;
    _studentidd = studentidd;
    _questionTestId = questionTestId;
    _assignmentChapterId = assignmentChapterId;
    _assignmentTopicId = assignmentTopicId;

    print("📋 Connectivity Service initialized for test: $testId");

    // Try to upload any pending answers immediately
    if (isOnline.value) {
      uploadPendingAnswers();
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    // Check initial connectivity
    Connectivity().checkConnectivity().then((result) {
      isOnline.value = result != ConnectivityResult.none;
      print(
        "📡 Connectivity Service: ${isOnline.value ? 'Online' : 'Offline'}",
      );
    });

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOffline = !isOnline.value;
        isOnline.value =
            results.isNotEmpty && results.first != ConnectivityResult.none;

        print(
          "📡 Connectivity changed: ${isOnline.value ? 'Online ✅' : 'Offline ❌'}",
        );

        // If we just came online, try to upload pending answers
        if (wasOffline && isOnline.value && _currentTestId != null) {
          print("🌐 Internet restored! Uploading pending answers...");
          uploadPendingAnswers();
        }
      },
      onError: (error) {
        print("❌ Connectivity monitoring error: $error");
      },
      cancelOnError: false,
    );
  }

  /// Upload all pending answers for the current test
  Future<void> uploadPendingAnswers() async {
    if (_currentTestId == null) {
      print("⚠️ No test context - skipping upload");
      return;
    }

    if (isUploading.value) {
      print("⏳ Upload already in progress - skipping");
      return;
    }

    if (!isOnline.value) {
      print("📴 Offline - cannot upload now");
      return;
    }

    isUploading.value = true;

    try {
      Box pendingBox;
      if (Hive.isBoxOpen('pending_answers_$_currentTestId')) {
        pendingBox = Hive.box('pending_answers_$_currentTestId');
      } else {
        pendingBox = await Hive.openBox('pending_answers_$_currentTestId');
      }

      if (pendingBox.isEmpty) {
        print("✅ No pending answers to upload");
        isUploading.value = false;
        return;
      }

      print("📤 Uploading ${pendingBox.length} pending answers...");

      int successCount = 0;
      int failCount = 0;
      final keysToDelete = <dynamic>[];

      for (var key in pendingBox.keys) {
        try {
          final data = jsonDecode(pendingBox.get(key));
          final answerData = Map<String, dynamic>.from(data);

          final qid = answerData['questionId'] as int;

          // Skip if already uploaded
          if (uploadedQuestions.contains(qid)) {
            keysToDelete.add(key);
            continue;
          }

          // Upload to server
          final success = await _submitQuestion(answerData);

          if (success) {
            successCount++;
            uploadedQuestions.add(qid);
            keysToDelete.add(key);
            print("✅ Uploaded QID $qid");
          } else {
            failCount++;
            print("⚠️ Failed to upload QID $qid");
          }
        } catch (e) {
          failCount++;
          print("❌ Error uploading answer: $e");
        }
      }

      // Delete successfully uploaded answers from Hive
      for (var key in keysToDelete) {
        await pendingBox.delete(key);
      }

      // Show notification
      if (successCount > 0) {
        Get.snackbar(
          "✅ Answers Synced",
          "$successCount answer(s) uploaded successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }

      if (failCount > 0) {
        print("⚠️ $failCount answers failed to upload, will retry later");
      }
    } catch (e) {
      print("❌ Error in uploadPendingAnswers: $e");
    } finally {
      isUploading.value = false;
    }
  }

  /// Submit a single question to the API
  Future<bool> _submitQuestion(Map<String, dynamic> answerData) async {
    try {
      final response = await http.post(
        Uri.parse(Adminurl.submitquestion),
        headers: {
          "MobAppStdAssign": "Mg97kdw-jm47r0t-lxn2mg-jdrtcs3-jk22mer",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "StudentId": answerData['studentId'],
          "QuestionId": answerData['questionId'],
          "BatchId": answerData['batchId'],
          "ExamTestId": answerData['examTestId'],
          "AssigtChapterId": int.tryParse(_assignmentChapterId ?? '0') ?? 0,
          "AssigtTopicId": int.tryParse(_assignmentTopicId ?? '0') ?? 0,
          "ChoiceOption": answerData['choiceOption'],
          "OptionCorrect": answerData['optionCorrect'],
          "OptionStatus": answerData['optionStatus'],
          "QuestionTestId": _questionTestId ?? '',
          "SchoolId": answerData['schoolId'],
          "CreateBy": answerData['studentId'],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Exception submitting question: $e");
      return false;
    }
  }

  /// Clean up test context when test is complete
  void clearTestContext() {
    _currentTestId = null;
    _schoolId = null;
    _studentId = null;
    _studentidd = null;
    _questionTestId = null;
    _assignmentChapterId = null;
    _assignmentTopicId = null;
    uploadedQuestions.clear();
    print("🧹 Connectivity Service: Test context cleared");
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
