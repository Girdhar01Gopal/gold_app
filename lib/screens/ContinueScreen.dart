import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/ContinueScreenController.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';

class ContinueScreen extends StatelessWidget {
  final ContinueScreenController controller = Get.put(ContinueScreenController()); // Initialize controller
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to control the drawer

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      drawer: AdminDrawer2(), // Add the drawer here to be opened by the IconButton
      appBar: AppBar(
        backgroundColor: Color(0xFF682D91), // Use FIITJEE purple color
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notes, color: Colors.white), // Notes icon
              onPressed: () {
                // Open the drawer when the notes icon is pressed
                _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the key
              },
            ),
            Expanded(
              child: Text(
                'Chemistry | Class11',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
            Obx(() => Text(
              'Your current GPA is ${controller.currentGPA.value}', // Use reactive GPA from controller
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // This will make the whole body scrollable vertically
          child: Padding(
            padding: EdgeInsets.all(16.w), // Use ScreenUtil for padding
            child: Column(
              children: [
                // Board Section Heading
                Text(
                  'Board Exam',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),

                // Horizontal scrollable list of subjects for Board
                Container(
                  height: 70.h, // Set a fixed height for the horizontal scroll list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 20, // We have 20 items
                    itemBuilder: (context, index) {
                      List<double> scores = [8.3, 8.5, 7.0];
                      return Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Subject ${index + 1}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Row(
                              children: List.generate(6, (dotIndex) {
                                if (dotIndex < scores.length) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 6.sp,
                                      child: Text(
                                        scores[dotIndex].toString(),
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6.sp,
                                    color: Colors.grey,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // JEE Main Section Heading
                Text(
                  'JEE Main',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),

                // Horizontal scrollable row of subjects for JEE Main
                Container(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Modify this value based on the number of subjects you want to show
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Column(
                          children: [
                            Container(
                              width: 100.w,
                              height: 50.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blueAccent,
                              ),
                              child: Text(
                                'Subject ${index + 1}',
                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  'JEE Advanced',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),

                // Horizontal scrollable row of subjects for JEE Advanced
                Container(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Modify this value based on the number of subjects you want to show
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Column(
                          children: [
                            Container(
                              width: 100.w,
                              height: 50.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.greenAccent,
                              ),
                              child: Text(
                                'Subject ${index + 1}',
                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Divider(),

                // Scores and Academic Details
                buildSubjectRow('Atomic Models', 8.3, 8.5),
                buildSubjectRow('Quantum Mechanics', 7.0, 8.0),
                buildSubjectRow('Mole Concept', 8.3, 8.5),
                buildSubjectRow('Periodic Properties', 8.0, 7.5),
                Divider(),
                Text(
                  'Academic Year: 2025',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Session will expire on 23-10-2025 at 00:01 am',
                  style: TextStyle(fontSize: 12.sp, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create a row for subject display with scores
  Widget buildSubjectRow(String subject, double score1, double score2) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            subject,
            style: TextStyle(fontSize: 16.sp),
          ),
          Row(
            children: [
              Text(
                score1.toString(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10.w),
              Text(
                score2.toString(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}