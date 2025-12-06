import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/controllers/mathscreencontroller.dart';
import 'package:gold_app/controllers/physicscontroller.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';

class Mathscreen extends GetView<Mathscreencontroller> {
   Mathscreen({super.key});
  // keep key as a state field so it's stable across builds
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper function to calculate CGPA based on completed assignments
  double calculateCGPA(List<Map<String, dynamic>> assignments) {
    double totalMarks = 0.0;
    int completedCount = 0;

    for (var assignment in assignments) {
      if (assignment['status'] == 'Completed') {
        var marks = assignment['marks'] as List<dynamic>;
        // Sum non-null marks safely
        final double sum = marks.where((mark) => mark != null).fold<double>(0.0, (p, e) => p + (e as double));
        final int nonNull = marks.where((mark) => mark != null).length;
        final double averageMarks = nonNull > 0 ? sum / nonNull : 0.0;

        totalMarks += averageMarks;
        completedCount++;
      }
    }

    if (completedCount == 0) return 0.0;
    return totalMarks / completedCount;
  }
 final Map<String, Map<String, List<Map<String, dynamic>>>> assignmentsData = {
  'Board': {
    'CALCULUS': [
      {'assignment': 'Limits and Continuity', 'marks': [8.0], 'status': 'Completed'},
      {'assignment': 'Differentiation', 'marks': [7.5], 'status': 'Completed'},
      {'assignment': 'Integration', 'marks': [6.5], 'status': 'Completed'},
    ],
    'ALGEBRA': [
      {'assignment': 'Quadratic Equations', 'marks': [9.0], 'status': 'Completed'},
      {'assignment': 'Matrices and Determinants', 'marks': [8.5], 'status': 'Completed'},
    ],
  },
  'JEE Main': {
    'CALCULUS': [
      {'assignment': 'Differentiation Rules', 'marks': [null], 'status': 'Not Started'},
      {'assignment': 'Integration Techniques', 'marks': [6.0], 'status': 'In Progress'},
      {'assignment': 'Application of Derivatives', 'marks': [7.5], 'status': 'Completed'},
    ],
    'LINEAR ALGEBRA': [
      {'assignment': 'Vector Algebra', 'marks': [5.5], 'status': 'Completed'},
      {'assignment': 'Matrices', 'marks': [8.0], 'status': 'Completed'},
    ],
  },
  'JEE Advanced': {
    'CONIC SECTIONS': [
      {'assignment': 'Parabola', 'marks': [9.0], 'status': 'Completed'},
      {'assignment': 'Ellipse', 'marks': [8.5], 'status': 'Completed'},
      {'assignment': 'Hyperbola', 'marks': [7.0], 'status': 'Completed'},
    ],
    'TRIGONOMETRY': [
      {'assignment': 'Trigonometric Identities', 'marks': [null], 'status': 'In Progress'},
      {'assignment': 'Properties of Triangles', 'marks': [6.5], 'status': 'Completed'},
      {'assignment': 'Heights and Distances', 'marks': [8.0], 'status': 'Completed'},
    ],
  }
};


  
  // Color helper for score-based circle color
  Color _scoreColor(double score) {
    if (score >= 10) return Colors.green.shade900;
    if (score >= 9) return Colors.green.shade700;
    if (score >= 7) return Colors.lightGreen.shade700;
    if (score >= 5) return Colors.yellow.shade700;
    if (score >= 3) return Colors.orange.shade700;
    if (score >= 2) return Colors.deepOrange.shade400;
    return Colors.red.shade700;
  }
  @override
  Widget build(BuildContext context) {
    final RxString selectedExam = 'Board'.obs;
    final List<String> exams = ['Board', 'JEE Main', 'JEE Advanced'];

  // Maharishi Learn brand palette (bright gold -> soft amber -> rich bronze)
  const Color primary = Color.fromARGB(255, 231, 217, 20); // bright gold
  const Color accent = Color(0xFFEB8A2A); // soft amber
  const Color bronze = Color(0xFFB8860B); // rich bronze

    Widget buildExamSelector() {
      return Row(
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
                  boxShadow: selected ? [BoxShadow(color: primary.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Text(e, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            );
          });
        }).toList(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer2(),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary, accent, bronze], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu,color: Colors.white,),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignments', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 2.h),
            Text('Track progress & continue tests', style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9))),
          ],
        ),
      
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            children: [
              buildExamSelector(),
              SizedBox(height: 12.h),

              Expanded(
                child: Obx(() {
                  final examData = assignmentsData[selectedExam.value];
                  if (examData == null) {
                    return Center(child: Text('No assignments for ${selectedExam.value}', style: TextStyle(fontSize: 14.sp, color: Colors.red.shade700)));
                  }

                  return ListView.separated(
                    itemCount: examData.keys.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, idx) {
                      final sectionKey = examData.keys.elementAt(idx);
                      final List<Map<String, dynamic>> items = examData[sectionKey] ?? [];
                      final int completed = items.where((it) => it['status'] == 'Completed').length;
                      final double progress = items.isNotEmpty ? (completed / items.length) : 0.0;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(sectionKey, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700))),
                                  Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(value: progress, minHeight: 8.h, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(accent)),
                              ),
                              SizedBox(height: 12.h),

                              // Assignments list preview (max 3 shown)
                              Column(
                                children: items.take(7).map((assignment) {
                                  final marks = (assignment['marks'] as List<dynamic>?) ?? [];
                                  final nonNull = marks.where((m) => m != null).toList();
                                  final bool hasMark = nonNull.isNotEmpty;
                                  final double? firstMark = hasMark ? (nonNull.first as num).toDouble() : null;
                                  final markDisplay = hasMark ? nonNull.map((m) => m.toString()).join(', ') : '';
                                  final status = assignment['status'] as String? ?? 'Not Started';

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 20.w,
                                      backgroundColor: hasMark ? _scoreColor(firstMark!) : (status == 'Completed' ? primary : Colors.grey.shade200),
                                      child: Text(
                                        hasMark ? firstMark!.toString() : '-',
                                        style: TextStyle(
                                          color: hasMark ? Colors.white : (status == 'Completed' ? Colors.white : Colors.black87),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(assignment['assignment'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                    subtitle: Row(children: [
                                      Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: status == 'Completed' ? Colors.green.shade50 : status == 'In Progress' ? Colors.orange.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: status == 'Completed' ? Colors.green.shade700 : status == 'In Progress' ? Colors.orange.shade700 : Colors.red.shade700, fontSize: 12.sp, fontWeight: FontWeight.w600))),
                                      SizedBox(width: 8.w),
                                      if (markDisplay.isNotEmpty) Text('Marks: $markDisplay', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
                                    ]),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        if (status != 'Completed') {
                                          final bool? confirm = await Get.dialog<bool>(
                                            AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              title: const Text('Open Test'),
                                              content: const Text('Do you want to open this test now?'),
                                              actions: [
                                                TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel', style: TextStyle(color: Colors.red))),
                                                ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: bronze), child: const Text('Yes',style: TextStyle(color: Colors.white))),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            Get.dialog(Center(child: LoadingAnimationWidget.dotsTriangle(size: 40.0, color: Colors.white)), barrierDismissible: false);
                                            await Future.delayed(const Duration(seconds: 2));
                                            Get.back();
                                            Get.offAllNamed(AdminRoutes.testscreen);
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: status == 'Completed' ? Colors.grey.shade400 : const Color.fromARGB(255, 76, 119, 8), padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      child: Text(status == 'Completed' ? 'View' : status == 'In Progress' ? 'Resume' : 'Start', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                                    ),
                                  );
                                }).toList(),
                              ),

                              if (items.length > 7) ...[
                                SizedBox(height: 8.h),
                                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text('View all', style: TextStyle(color: primary, fontWeight: FontWeight.w600)))),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
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
