// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../infrastructure/routes/admin_routes.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  String? selectedYear = '2025'; // Default selected year

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
   // ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // AppBar background color set to red
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Removes default padding from AppBar
        title: Text(
          'Your current class 11(AY 2025)', // Replaced with the required text
          style: TextStyle(
            fontSize: 12.sp, // Adjust text size based on screen size
            color: Colors.white,
          ),
        ),
        actions: [
          // Scrollable Horizontal Button Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Make buttons scrollable horizontally
            child: Row(
              children: [
                // Button 1 - Reset
                ElevatedButton(
                  onPressed: () {
                    _showResetDialog(context); // Show reset dialog on button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background for the button
                    side: BorderSide(color: Colors.white), // White border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Circular border
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Button padding
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp, // Adjust text size for small buttons
                    ),
                  ),
                ),
                SizedBox(width: 8.w), // Add space between buttons
                // Button 2 - Change Academic Year
                ElevatedButton(
                  onPressed: () {
                    _showYearDropdownDialog(context); // Show Year Dropdown on button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background for the button
                    side: BorderSide(color: Colors.white), // White border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Circular border
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Button padding
                  ),
                  child: Text(
                    'Change Academic Year',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp, // Adjust text size for small buttons
                    ),
                  ),
                ),
                SizedBox(width: 10.w), // Add space between buttons
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Blue section
          Container(
            width: 150.w, // Adjust width based on screen size
            color: Colors.blue, // Left side background color
            child: Column(
              children: [
                // Header with dark blue background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  color: Colors.blue[900], // Dark blue background for the header
                  child: Text(
                    'Assignment',  // Text with a prefix "Assign"
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Left section content below header
                Expanded(
                  child: Center(
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // FIITJEE Logo at the bottom of the left section
                // Padding(
                //   padding: EdgeInsets.symmetric(vertical: 1.h), // Add padding for spacing
                //   child: Image.asset(
                //     'assets/images/FIITJEE_Logo.png', // Correct image path
                //     height: 80.h, // Adjust the image height as per your preference
                //     width: 80.w, // Adjust the image width as per your preference
                //   ),
                // ),
              ],
            ),
          ),
          // Right side - White section with cards
          Expanded(
            child: Container(
              color: Colors.white, // Right side background color
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card 1 - Chemistry
                      Card(
                        color: Colors.grey[200],
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.blue[900]),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Chemistry' ,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.offAllNamed(AdminRoutes.CONTINUE_SCREEN);
                                  // Add Continue functionality here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900], // Red background for the button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Circular border
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Button padding
                                ),
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp, // Button text size
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h), // Space between cards
                      // Card 2 - Mathematics (Unchanged)
                      Card(
                        color: Colors.grey[200],
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.blue[900]),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Maths',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.offAllNamed(AdminRoutes.mathscreen);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900], // Red background for the button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Circular border
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Button padding
                                ),
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp, // Button text size
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h), // Space between cards
                      // Card 3 - Physics (Unchanged)
                      Card(
                        color: Colors.grey[200],
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.blue[900]),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Physics',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Add Continue functionality here
                                  Get.offAllNamed(AdminRoutes.physics);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900], // Red background for the button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20), // Circular border
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Button padding
                                ),
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp, // Button text size
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
// Function to show the Reset Confirmation Dialog
void _showResetDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r), // Smooth rounded corners
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
        actionsPadding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),

        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Confirm Reset',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        content: Text(
          'If you continue, the app will reset to its initial state as if it’s being used for the first time. '
          'This will clear all local data and preferences.',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black54,
            height: 1.4,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              textStyle: TextStyle(fontSize: 12.sp),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Add your reset logic here
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 16),
            label: Text(
              'Reset Now',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
          ),
        ],
      );
    },
  );
}

// Function to show the Change Academic Year Dropdown
void _showYearDropdownDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Select Academic Year',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        content: SizedBox(
          width: 200.w, // Adjust width for dropdown box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedYear,
                isExpanded: true, // Makes dropdown take full width
                onChanged: (String? newValue) {
                  selectedYear = newValue;
                  Navigator.of(context).pop(); // Close dialog after selection
                },
                items: <String>['2025', '2026']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog on Cancel
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 12.sp),
            ),
          ),
        ],
      );
    },
  );
}
}
