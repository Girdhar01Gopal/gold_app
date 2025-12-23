import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/Model/assignmentmodel.dart';
import 'package:gold_app/appurl/adminurl.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';
import '../infrastructure/routes/admin_routes.dart';

class ContinueScreen extends StatefulWidget {
  ContinueScreen({super.key});

  @override
  State<ContinueScreen> createState() => _ContinueScreenState();
}

class _ContinueScreenState extends State<ContinueScreen> {
  var allAssignments = <String, Map<String, AssignmentChapters>>{}; // Store all assignments by exam type
  var selectedExam = 'JEE Advanced'.obs; // Default selected exam
    var schoolid = ''.obs;
          var studentid = ''.obs; 
          var subjectId = ''.obs;

  // Define color constants
  final Color primary = ColorPainter.primaryColor;
  final Color accent = ColorPainter.accentColor;
  final Color bronze = const Color(0xFFCD7F32);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  subjectId.value = Get.arguments['subjectId'] ?? '';
  schoolid.value = await PrefManager().readValue(key: PrefConst.SchoolId);
  studentid.value = await PrefManager().readValue(key: PrefConst.StudentId);
  // Fetch assignments on screen load
  await assignment();
}

  Future<void> assignment() async {
    try {
      final response = await http.get(Uri.parse("${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}"));
print("Request URL: ${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print("API Response: $jsonResponse");
        
        if (jsonResponse['data'] != null && jsonResponse['data']['AssignmentExam'] != null) {
          final assignmentExam = jsonResponse['data']['AssignmentExam'] as Map<String, dynamic>;
          
          setState(() {
            allAssignments.clear();
            
            // Loop through each exam type (JEE Advanced, Board, etc.)
            assignmentExam.forEach((examType, examData) {
              if (examData is Map<String, dynamic> && examData['AssignmentChapters'] != null) {
                final chapters = examData['AssignmentChapters'] as Map<String, dynamic>;
                
                // Create a map to store chapters for this exam type
                Map<String, AssignmentChapters> examChapters = {};
                
                // Loop through each chapter
                chapters.forEach((chapterName, chapterData) {
                  if (chapterData is List) {
                    // Create AssignmentChapters object
                    final assignmentChapter = AssignmentChapters(
                      assignments: chapterData.map((item) => 
                        Assignment.fromJson(item as Map<String, dynamic>)
                      ).toList(),
                    );
                    
                    examChapters[chapterName] = assignmentChapter;
                  }
                });
                
                // Store chapters under exam type
                allAssignments[examType] = examChapters;
              }
            });
          });
        }
      } else {
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in fetching assignments: $e");
    }
  }

  // Get assignments for selected exam
  Map<String, AssignmentChapters> getFilteredAssignments() {
    return allAssignments[selectedExam.value] ?? {};
  }

  // Function to display the exam selector
  Widget buildExamSelector() {
    // Get available exam types from API response
    final exams = allAssignments.keys.toList();
    
    if (exams.isEmpty) {
      return SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: exams.map((e) {
          return Obx(() {
            final selected = selectedExam.value == e;
            return GestureDetector(
              onTap: () => selectedExam.value = e,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? primary : Colors.grey.shade300),
                  boxShadow: selected
                      ? [BoxShadow(color: primary.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Text(
                  e,
                  style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'attempted':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to build info chips
  Widget _buildInfoChip(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer2(),
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Select exam type below',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Exam Selector Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Exam Type',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  buildExamSelector(),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
                child: Obx(() {
                  final filteredAssignments = getFilteredAssignments();
                  
                  if (allAssignments.isEmpty) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: primary,
                        size: 50,
                      ),
                    );
                  }
                  
                  if (filteredAssignments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                          SizedBox(height: 16.h),
                          Text(
                            'No assignments found for ${selectedExam.value}',
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: filteredAssignments.keys.length,
                    itemBuilder: (context, index) {
                      String chapterName = filteredAssignments.keys.elementAt(index);
                      AssignmentChapters chapters = filteredAssignments[chapterName]!;
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chapter Header
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primary.withOpacity(0.08),
                                    accent.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [primary, accent],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.library_books, color: Colors.white, size: 22),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapterName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          '${chapters.assignments?.length ?? 0} Assignments',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Assignments List
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chapters.assignments?.length ?? 0,
                                itemBuilder: (context, idx) {
                                  final assignment = chapters.assignments![idx];
                                  final isAttempted = assignment.aStatus?.toLowerCase() == 'attempted';
                                  final statusColor = _getStatusColor(assignment.aStatus);
                                  
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 48.w,
                                                height: 48.h,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [primary.withOpacity(0.8), accent],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  isAttempted ? Icons.check_circle : Icons.play_arrow_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      assignment.testName ?? '',
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      assignment.assignmentTopic ?? 'N/A',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),
                                          Row(
                                            children: [
                                              _buildInfoChip(
                                                Icons.timer_outlined,
                                                '${assignment.totalMinutes} min',
                                                Colors.blue.shade50,
                                                Colors.blue.shade700,
                                              ),
                                              SizedBox(width: 8.w),
                                              _buildInfoChip(
                                                Icons.star_outline,
                                                '${assignment.testTotalMarks} marks',
                                                Colors.orange.shade50,
                                                Colors.orange.shade700,
                                              ),
                                              SizedBox(width: 8.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  assignment.aStatus ?? 'Not Started',
                                                  style: TextStyle(
                                                    fontSize: 8.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Handle test start/continue
                                                print('${isAttempted ? 'Continue' : 'Start'} Test: ${assignment.testName}');
                                                // Add your navigation logic here
                                                Get.offAllNamed(AdminRoutes.testscreen, arguments: {
                                                  'testId': assignment.testId,
                                                  'passcode': "1",
                                                  'assignmenttopicid': assignment.assigtTopicId?.toString() ?? '',
                                                  'assignmentchapterid': assignment.assigtChapterId?.toString() ?? '',
                                                  'timelimit': assignment.totalMinutes?.toString() ?? '',
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isAttempted ? accent : primary,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                elevation: 2,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    isAttempted ? Icons.refresh : Icons.play_arrow_rounded,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    isAttempted ? 'Try Again' : 'Start Test',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
  }
}

class ColorPainter {
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color secondaryColor = Color(0xFFFFA000);
  static const Color accentColor = Color(0xFF4CA1AF);

  static LinearGradient get gradientBackground => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get buttonGradient => LinearGradient(
        colors: [primaryColor, accentColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static BoxDecoration get boxDecoration => BoxDecoration(
        gradient: gradientBackground,
        borderRadius: BorderRadius.circular(25),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            blurRadius: 12,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get buttonBoxDecoration => BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(30),
      );
}

