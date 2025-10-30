// screens/mathscreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/controllers/mathscreencontroller.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';

class Mathscreen extends GetView<Mathscreencontroller> {
  const Mathscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxString selectedExam = 'Board'.obs;
    final List<String> exams = ['Board', 'JEE Main', 'JEE Advanced'];

    // 📘 Math data
    final Map<String, List<Map<String, dynamic>>> data = {
      'SETS, RELATIONS & FUNCTIONS': [
        {'topic': 'Sets & Subsets', 'scores': [8.0, 7.5, null, 8.2, 7.8, null]},
        {'topic': 'Relations & Functions', 'scores': [7.5, 8.0, 8.2, null, 7.9, 8.0]},
      ],
      'TRIGONOMETRY': [
        {'topic': 'Trigonometric Ratios', 'scores': [8.5, 8.3, 8.0, 7.5, 8.8, null]},
        {'topic': 'Trigonometric Equations', 'scores': [7.8, 8.0, null, 7.0, 6.9, null]},
      ],
      'ALGEBRA': [
        {'topic': 'Quadratic Equations', 'scores': [8.4, 8.0, 7.5, 8.8, 7.6, null]},
        {'topic': 'Sequences & Series', 'scores': [null, 7.0, 7.5, null, 8.0, null]},
      ],
      'CALCULUS': [
        {'topic': 'Limits & Continuity', 'scores': [7.8, 8.2, 8.0, 7.6, null, null]},
        {'topic': 'Differentiation', 'scores': [8.3, 8.5, 7.9, 8.0, 7.8, null]},
      ],
    };

    final List<String> phases = ['PHASE I', 'PHASE II', 'PHASE III', 'PHASE IV'];

    Color _scoreColor(double score) {
      if (score >= 8) return Colors.green.shade700;
      if (score >= 6) return Colors.lightGreen.shade700;
      return Colors.orange.shade700;
    }

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        bool? exit = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Exit Confirmation'),
            content: const Text('Are you sure you want to go back?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF682D91),
                ),
                onPressed: () => Get.back(result: true),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return exit ?? false;
      },

      child: Scaffold(
        key: scaffoldKey,
        drawer: AdminDrawer2(),
        backgroundColor: Colors.grey.shade100,

        // ========= APP BAR =========
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(270.h),
          child: AppBar(
            backgroundColor: const Color(0xFF682D91),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => scaffoldKey.currentState?.openDrawer(),
                        ),
                        Expanded(
                          child: Text(
                            'Mathematics | Class 11',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Assignment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: Obx(() => Text(
                          'Your current GPA is ${controller.currentGPA.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 80.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: exams.map((e) {
                        return Obx(() {
                          final selected = selectedExam.value == e;
                          return GestureDetector(
                            onTap: () => selectedExam.value = e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ========= BODY =========
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: phases.map((phase) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // ==== Phase Header ====
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 6.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6DFCF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  phase,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),

                            // ==== Chapter + Topics ====
                            ...data.entries.map((section) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12.h),
                                  Text(
                                    section.key,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Divider(
                                      color: Colors.deepPurple.shade100,
                                      thickness: 1),

                                  // === Topics and Circles ===
                                  ...section.value.map((topic) {
                                    final scores =
                                        topic['scores'] as List<dynamic>;
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.h, horizontal: 4.w),
                                      child: Row(
                                        children: [
                                          // LEFT: Topic
                                          SizedBox(
                                            width: 0.30.sw,
                                            child: Text(
                                              topic['topic'],
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),

                                          // RIGHT: 6 circles
                                          SizedBox(
                                            width: 0.60.sw,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children:
                                                  List.generate(6, (i) {
                                                final val = scores[i];
                                                final hasScore = val != null;
                                                return Container(
                                                  height: 20.w,
                                                  width: 20.w,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: hasScore
                                                        ? _scoreColor(val)
                                                        : Colors.grey.shade300,
                                                  ),
                                                  child: hasScore
                                                      ? Text(
                                                          val.toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 8.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : null,
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
