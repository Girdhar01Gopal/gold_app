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
  var allAssignments =
      <
        String,
        Map<String, AssignmentChapters>
      >{}; // Store all assignments by exam type
  var selectedExam = 'JEE Advanced'.obs; // Default selected exam
  var schoolid = ''.obs;
  var studentid = ''.obs;
  var subjectId = ''.obs;

  var subjectname = ''.obs;

  var classs = ''.obs;

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
    subjectname.value = Get.arguments['subjectName'] ?? '';
    schoolid.value = await PrefManager().readValue(key: PrefConst.SchoolId);
    studentid.value = await PrefManager().readValue(key: PrefConst.StudentId);
    classs.value = await PrefManager().readValue(key: PrefConst.className);
    // Fetch assignments on screen load
    await assignment();
  }

  Future<void> assignment() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}",
        ),
      );
      print(
        "Request URL: ${Adminurl.assignment}/${schoolid.value}/${studentid.value}/${subjectId.value}",
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print("API Response: $jsonResponse");

        if (jsonResponse['data'] != null &&
            jsonResponse['data']['AssignmentExam'] != null) {
          final assignmentExam =
              jsonResponse['data']['AssignmentExam'] as Map<String, dynamic>;

          setState(() {
            allAssignments.clear();

            // Loop through each exam type (JEE Advanced, Board, etc.)
            assignmentExam.forEach((examType, examData) {
              if (examData is Map<String, dynamic> &&
                  examData['AssignmentChapters'] != null) {
                final chapters =
                    examData['AssignmentChapters'] as Map<String, dynamic>;

                // Create a map to store chapters for this exam type
                Map<String, AssignmentChapters> examChapters = {};

                // Loop through each chapter
                chapters.forEach((chapterName, chapterData) {
                  if (chapterData is List) {
                    // Create AssignmentChapters object
                    final assignmentChapter = AssignmentChapters(
                      assignments: chapterData
                          .map(
                            (item) => Assignment.fromJson(
                              item as Map<String, dynamic>,
                            ),
                          )
                          .toList(),
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
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? primary : Colors.grey.shade300,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
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
  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color bgColor,
    Color textColor,
  ) {
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
              fontSize: 4.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCgpaColor(double cgpa) {
    if (cgpa >= 9.0) {
      return const Color(0xFF2E7D32);
    }
    if (cgpa >= 7.0) {
      return const Color(0xFF1565C0);
    }
    if (cgpa >= 5.0) {
      return const Color(0xFFEF6C00);
    }
    return const Color(0xFFC62828);
  }

  Widget _buildCgpaCircle(double cgpa) {
    final color = _getCgpaColor(cgpa);
    return GestureDetector(
      onTap: (){
          // SUCCESS → GO TO TEST SCREEN
    Get.offAllNamed(
      AdminRoutes.testscreen,
      arguments: {
        'testId': "85228368",
        'passcode': "8689512515",
      },
    );
      },
      child: Container(
        width: 15.w,
        height: 35.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.16),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.2),
        ),
        child: Text(
          cgpa.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 6.2.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildChapterRow(String title, List<double> cgpas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            title,
            style: TextStyle(fontSize: 4.sp, color: Colors.black87),
          ),
        ),
        ...cgpas.map((cgpa) {
          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: _buildCgpaCircle(cgpa),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer2(),
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF5F6FA),
      appBar: AppBar(
        toolbarHeight: 170, // increase appbar height from here
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subjectname.value.isNotEmpty
                  ? "${subjectname.value} - ${classs.value.replaceAll('"', '').trim()}"
                  : 'Continue your tests',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 20.sp),
                Text(
                  'Board',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Jee Main',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Jee Advanced',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Text(
                'Select the chapter you want to continue',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
            _buildChapterRow('Indicators And Solublity Product', [
              9.8,
              8.2,
              7.4,
              5.6,
              4.2,
              3.1,
            ]),
            _buildChapterRow('Ionic Equilibrium', [
              8.8,
              7.6,
              6.9,
              5.1,
              4.8,
              2.9,
            ]),
            _buildChapterRow('Organic Chemistry', [
              9.2,
              8.9,
              7.2,
              6.4,
              5.5,
              4.0,
            ]),
            _buildChapterRow('Thermodynamics', [9.5, 8.0, 7.1, 6.2, 5.2, 3.8]),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Text(
                'Select the chapter you want to continue2',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              ),
            ),
            _buildChapterRow('Chemical Kinetics', [
              8.7,
              7.9,
              6.0,
              5.4,
              4.6,
              3.3,
            ]),
            _buildChapterRow('Electrochemistry', [
              9.0,
              8.3,
              7.0,
              6.1,
              5.0,
              4.4,
            ]),
            _buildChapterRow('Surface Chemistry', [
              7.8,
              7.0,
              6.2,
              5.5,
              4.9,
              3.6,
            ]),
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
