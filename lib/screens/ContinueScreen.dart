// screens/ContinueScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import '../controllers/ContinueScreenController.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';

class ContinueScreen extends GetView<ContinueScreenController> {
  const ContinueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxString selectedExam = 'Board'.obs;
    final List<String> exams = ['Board', 'JEE Main', 'JEE Advanced'];

    final Map<String, List<Map<String, dynamic>>> data = {
      'ATOMIC STRUCTURE': [
        {'topic': 'Atomic Models', 'scores': [3.0, null, null, 5.0, null, null]},
        {'topic': 'Quantum Mechanics', 'scores': [null, null, null, 8.0, null, null]},
      ],
      'BCC': [
        {'topic': 'Mole Concept', 'scores': [0.3, null, 2.0, 7.0, null, null]},
      ],
      'PERIODIC PROPERTIES': [
        {'topic': 'Periodic Properties', 'scores': [null, null, null, 8.0, null, null]},
      ],
    };

    final List<String> phases = ['PHASE I', 'PHASE II', 'PHASE III', 'PHASE IV'];

   Color _scoreColor(double score) {
  if (score >= 10) {
    return Colors.green.shade900; // Dark green for perfect score
  } else if (score >= 9) {
    return Colors.green.shade700; // Deep green (excellent)
  } else if (score >= 7) {
    return Colors.lightGreen.shade700; // Light green (good)
  } else if (score >= 5) {
    return Colors.yellow.shade700; // Yellow (average)
  } else if (score >= 3) {
    return Colors.orange.shade700; // Orange (below average)
  } else if (score >= 2) {
    return Colors.deepOrange.shade400; // Light orange (poor)
  } else {
    return Colors.red.shade700; // Red (critical / fail)
  }
}


    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await Get.dialog<bool>(
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
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4a4a4a),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return exitApp ?? false;
      },

      child: Scaffold(
        key: scaffoldKey,
        drawer: AdminDrawer2(),
        backgroundColor: Colors.grey.shade100,

        // ============= APP BAR =============
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(280.h),
          child: AppBar(
            backgroundColor: const Color(0xFF4a4a4a),
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
                            'Chemistry | Class 11',
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

        // ============= BODY =============
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
                                          // LEFT column (30%)
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
                                              children: List.generate(6, (i) {
                                                final val = scores[i];
                                                final hasScore = val != null;
                                                return GestureDetector(
  onTap: () async {
    if (!hasScore) {
      // Step 1: show confirmation dialog
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Open Test'),
          content: const Text('Are you sure you want to open this test?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4a4a4a),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Step 2: show circular loader dialog for 3–5 sec
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4a4a4a),
              strokeWidth: 4,
            ),
          ),
          barrierDismissible: false,
        );

        // Simulate loading delay
        await Future.delayed(const Duration(seconds: 4));

        // Close loader
        Get.back();

        // Step 3: navigate to test screen
        Get.offAllNamed(AdminRoutes.testscreen);
      }
    }
  },
  child: Container(
    height: 20.w,
    width: 20.w,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: hasScore ? _scoreColor(val) : Colors.grey.shade300,
      border: Border.all(
        color: hasScore ? Colors.transparent : Colors.deepPurple.shade100,
        width: hasScore ? 0 : 1.5,
      ),
    ),
    child: hasScore
        ? Text(
            val.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
            ),
          )
        : Icon(Icons.add, size: 10.sp, color: Colors.black54),
  ),
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
