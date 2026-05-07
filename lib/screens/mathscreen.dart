// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gold_app/Model/assignmentmodel.dart';
// import 'package:gold_app/appurl/adminurl.dart';
// import 'package:gold_app/infrastructure/routes/admin_routes.dart';
// import 'package:gold_app/localstorage.dart';
// import 'package:gold_app/prefconst.dart';
// import 'package:http/http.dart' as http;
// import 'package:loading_animation_widget/loading_animation_widget.dart';

// import '../infrastructure/app_drawer/admin_drawer2.dart';

// class Mathscreen extends StatefulWidget {
//   const Mathscreen({super.key});

//   @override
//   State<Mathscreen> createState() => _MathscreenState();
// }

// class _MathscreenState extends State<Mathscreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   // examType -> chapterName -> list of tests
//   final Map<String, Map<String, List<Test>>> allData = {};
//   List<String> examTypes = [];
//   String selectedExam = '';

//   bool isLoading = true;
//   String? error;

//   String schoolId = '';
//   String studentId = '';
//   String subjectId = '';
//   String subjectName = '';

//   static const Color primary = Color.fromARGB(255, 231, 217, 20);
//   static const Color accent = Color(0xFFEB8A2A);
//   static const Color bronze = Color(0xFFB8860B);

//   static const List<_TimeModeOption> _timeModes = [
//     _TimeModeOption(label: 'Set average time per Question 2 min', value: 'average'),
//     _TimeModeOption(label: 'Set average time per Question 3 min', value: 'medium'),
//     _TimeModeOption(label: 'Set average time per Question 5 min', value: 'hard', color: Color(0xFFFFA000)),
//     _TimeModeOption(label: 'No Time limit', value: 'no_limit'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     subjectId = Get.arguments?['subjectId']?.toString() ?? '';
//     subjectName = Get.arguments?['subjectName']?.toString() ?? 'Assignments';
//     schoolId = await PrefManager().readValue(key: PrefConst.SchoolId) ?? '';
//     studentId = await PrefManager().readValue(key: PrefConst.StudentId) ?? '';
//     await _fetchAssignments();
//   }

//   Future<void> _fetchAssignments() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final url = '${Adminurl.assignment}/$schoolId/$studentId/$subjectId';
//       debugPrint('Mathscreen API: $url');
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body) as Map<String, dynamic>;
//         _parseResponse(json);
//       } else {
//         throw Exception('HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Mathscreen fetch error: $e');
//       if (mounted) setState(() => error = 'Failed to load assignments. Please try again.');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _parseResponse(Map<String, dynamic> json) {
//     allData.clear();

//     final examMap = json['data']?['AssignmentExam'] as Map<String, dynamic>?;
//     if (examMap == null) return;

//     examMap.forEach((examType, examData) {
//       if (examData is! Map<String, dynamic>) return;
//       final chapters = examData['AssignmentChapters'] as Map<String, dynamic>?;
//       if (chapters == null) return;

//       final Map<String, List<Test>> chapterMap = {};
//       chapters.forEach((chapterName, chapterData) {
//         if (chapterData is List) {
//           chapterMap[chapterName] = chapterData
//               .whereType<Map<String, dynamic>>()
//               .map((item) => Test.fromJson(item))
//               .toList();
//         }
//       });

//       if (chapterMap.isNotEmpty) {
//         allData[examType] = chapterMap;
//       }
//     });

//     examTypes = allData.keys.toList();
//     if (examTypes.isNotEmpty) selectedExam = examTypes.first;
//   }

//   Color _scoreColor(double score) {
//     if (score >= 9) return Colors.green.shade700;
//     if (score >= 7) return Colors.lightGreen.shade700;
//     if (score >= 5) return Colors.yellow.shade700;
//     if (score >= 3) return Colors.orange.shade700;
//     return Colors.red.shade700;
//   }

//   Future<void> _openTest(Test test) async {
//     if (test.status == 'Completed') return;

//     final mode = await Get.dialog<String>(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Set time limit'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: _timeModes
//               .map((opt) => Padding(
//                     padding: const EdgeInsets.only(bottom: 6),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => Get.back(result: opt.value),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: opt.color ?? primary,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                         child: Text(opt.label, style: const TextStyle(fontSize: 13)),
//                       ),
//                     ),
//                   ))
//               .toList(),
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//         ],
//       ),
//       barrierDismissible: false,
//     );

//     if (mode == null) return;

//     Get.offAllNamed(
//       AdminRoutes.testscreen,
//       arguments: {
//         'testId': test.testId ?? '',
//         'passcode': test.questionTestId?.toString() ?? '',
//         'questionMode': mode,
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: AdminDrawer2(),
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [primary, accent, bronze],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.white),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(subjectName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
//             Text('Track progress & continue tests', style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9))),
//           ],
//         ),
//       ),
//       body: SafeArea(child: _buildBody()),
//     );
//   }

//   Widget _buildBody() {
//     if (isLoading) {
//       return Center(
//         child: LoadingAnimationWidget.dotsTriangle(size: 48, color: primary),
//       );
//     }

//     if (error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
//             SizedBox(height: 12.h),
//             Text(error!, style: TextStyle(fontSize: 14.sp, color: Colors.red.shade700), textAlign: TextAlign.center),
//             SizedBox(height: 16.h),
//             ElevatedButton(
//               onPressed: _fetchAssignments,
//               style: ElevatedButton.styleFrom(backgroundColor: primary),
//               child: const Text('Retry', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       );
//     }

//     if (allData.isEmpty) {
//       return Center(
//         child: Text('No assignments found.', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
//       );
//     }

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//       child: Column(
//         children: [
//           _buildExamSelector(),
//           SizedBox(height: 12.h),
//           Expanded(child: _buildChapterList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildExamSelector() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: examTypes.map((exam) {
//           final selected = selectedExam == exam;
//           return GestureDetector(
//             onTap: () => setState(() => selectedExam = exam),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               margin: EdgeInsets.symmetric(horizontal: 6.w),
//               padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: selected ? primary : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: selected ? primary : Colors.grey.shade300),
//                 boxShadow: selected
//                     ? [BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
//                     : null,
//               ),
//               child: Text(
//                 exam,
//                 style: TextStyle(
//                   color: selected ? Colors.white : Colors.black87,
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildChapterList() {
//     final chapters = allData[selectedExam];
//     if (chapters == null || chapters.isEmpty) {
//       return Center(
//         child: Text('No assignments for $selectedExam', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
//       );
//     }

//     return ListView.separated(
//       itemCount: chapters.length,
//       separatorBuilder: (_, __) => SizedBox(height: 12.h),
//       itemBuilder: (context, idx) {
//         final chapterName = chapters.keys.elementAt(idx);
//         final tests = chapters[chapterName] ?? [];
//         final completed = tests.where((t) => t.status == 'Completed').length;
//         final progress = tests.isNotEmpty ? completed / tests.length : 0.0;

//         return Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           elevation: 3,
//           child: Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(chapterName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
//                     ),
//                     Text('$completed/${tests.length}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
//                     SizedBox(width: 6.w),
//                     Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 7.h,
//                     backgroundColor: Colors.grey.shade200,
//                     valueColor: const AlwaysStoppedAnimation(accent),
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 ...tests.map((test) => _buildTestTile(test)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTestTile(Test test) {
//     final status = test.status ?? 'Not Started';
//     final marks = test.testTotalMarks;
//     final hasMarks = marks != null && marks.isNotEmpty && marks != '0';
//     final marksVal = double.tryParse(marks ?? '') ?? 0.0;

//     Color statusColor;
//     Color statusBg;
//     switch (status) {
//       case 'Completed':
//         statusColor = Colors.green.shade700;
//         statusBg = Colors.green.shade50;
//         break;
//       case 'In Progress':
//         statusColor = Colors.orange.shade700;
//         statusBg = Colors.orange.shade50;
//         break;
//       default:
//         statusColor = Colors.red.shade700;
//         statusBg = Colors.red.shade50;
//     }

//     String btnLabel;
//     Color btnColor;
//     switch (status) {
//       case 'Completed':
//         btnLabel = 'View';
//         btnColor = Colors.grey.shade400;
//         break;
//       case 'In Progress':
//         btnLabel = 'Resume';
//         btnColor = const Color.fromARGB(255, 76, 119, 8);
//         break;
//       default:
//         btnLabel = 'Start';
//         btnColor = const Color.fromARGB(255, 76, 119, 8);
//     }

//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: CircleAvatar(
//         radius: 20.w,
//         backgroundColor: hasMarks ? _scoreColor(marksVal) : (status == 'Completed' ? primary : Colors.grey.shade200),
//         child: Text(
//           hasMarks ? marksVal.toStringAsFixed(0) : '-',
//           style: TextStyle(
//             color: hasMarks || status == 'Completed' ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 12.sp,
//           ),
//         ),
//       ),
//       title: Text(test.testName ?? 'Assignment', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
//       subtitle: Wrap(
//         spacing: 6,
//         crossAxisAlignment: WrapCrossAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//             decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
//             child: Text(status, style: TextStyle(color: statusColor, fontSize: 11.sp, fontWeight: FontWeight.w600)),
//           ),
//           if (test.totalMinutes != null)
//             Text('${test.totalMinutes} min', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
//           if (hasMarks)
//             Text('Marks: $marks', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
//         ],
//       ),
//       trailing: ElevatedButton(
//         onPressed: status == 'Completed' ? null : () => _openTest(test),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: btnColor,
//           disabledBackgroundColor: Colors.grey.shade400,
//           padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         child: Text(btnLabel, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
//       ),
//     );
//   }
// }

// class _TimeModeOption {
//   final String label;
//   final String value;
//   final Color? color;
//   const _TimeModeOption({required this.label, required this.value, this.color});
// }
