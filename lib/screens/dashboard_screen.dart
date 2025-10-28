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
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // AppBar background color set to red
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Removes default padding from AppBar
        title: Text(
          'Your current class 11(AY 2025)', // Replaced with the required text
          style: TextStyle(
            fontSize: 20.sp, // Adjust text size based on screen size
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
                      fontSize: 12.sp, // Adjust text size for small buttons
                    ),
                  ),
                ),
                SizedBox(width: 10.w), // Add space between buttons
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
                      fontSize: 12.sp, // Adjust text size for small buttons
                    ),
                  ),
                ),
                SizedBox(width: 10.w), // Add space between buttons
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h), // Add padding for spacing
                    child: Image.asset(
                      'assets/images/FIITJEE_Logo.png', // Correct image path
                      height: 80.h, // Adjust the image height as per your preference
                      width: 80.w, // Adjust the image width as per your preference
                    ),
                  ),
                ],
              ),
            ),
            // Right side - White section with cards
            Expanded(
              child: Container(
                color: Colors.white, // Right side background color
                child: Padding(
                  padding: EdgeInsets.all(10.h),
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
                                    'Chem ' ,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.toNamed(AdminRoutes.CONTINUE_SCREEN);
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
                                  Get.toNamed(AdminRoutes.CONTINUE_SCREEN);
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
                                  Get.toNamed(AdminRoutes.CONTINUE_SCREEN);
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
          ],
        ),
      ),
    );
  }

  // Function to show the Reset Dialog
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'RESET',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            'If you continue, your app will behave as if being used for the first time.',
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue, // Blue color for Cancel button
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Add Reset functionality here
                Navigator.of(context).pop(); // Dismiss the dialog after reset
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.blue, // Blue color for Continue button
                ),
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
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Academic Year',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: Container(
            width: 200.w, // Adjust width for dropdown box
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    selectedYear = newValue;
                    Navigator.of(context).pop(); // Close dialog after selection
                  },
                  items: <String>['2025', '2026']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: 150.w, // Square box width for dropdown
                        padding: EdgeInsets.all(10.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue[900],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
