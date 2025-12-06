import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gold_app/infrastructure/routes/admin_routes.dart';
import '../controllers/usage_controller.dart';

class UsageScreen extends StatelessWidget {
  final UsageController controller = Get.find();

  // Maharishi Learn brand palette (bright gold -> soft amber -> rich bronze)
  static const Color primary = Color.fromARGB(255, 231, 217, 20); // bright gold
  static const Color accent = Color(0xFFEB8A2A); // soft amber
  static const Color bronze = Color(0xFFB8860B); // rich bronze

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent, bronze],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Usage',
          style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.offAllNamed(AdminRoutes.homeScreen),
            child: Text(
              'Home',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MAHARISHI LEARN APP USAGE GUIDE',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: bronze,
                ),
              ),
              SizedBox(height: 10.h),

              Text(
                "When you launch the app for the first time without internet, it will not work. Once connected, the app will download your Home Screen from the server — valid for 7 days (session lifetime). You can access the app offline during this period.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),

              SizedBox(height: 20.h),
              _sectionHeader("Assignment Button Colors"),

             
              _colorDescription("Green", "Assignment opened — you are supposed to attempt it now."),
              _colorDescription("Grey", "Assignment Completed you did not attempt again."),
              _colorDescription("Red", "Attempted with extremely poor score."),
              _colorDescription("Light Red", "Attempted with poor but slightly better score."),
              _colorDescription("Orange", "Attempted, score is not good."),
              _colorDescription("Yellow", "Attempted, score is moderate."),
              _colorDescription("Light Green", "Attempted, score is satisfactory."),
              _colorDescription("Dark Green", "Attempted, score is good."),

              SizedBox(height: 25.h),
              _sectionHeader("Assignment Download & Validity"),

              Text(
                "When you click any button, the app downloads the assignment (valid for the same 7-day session as the Home Screen). For example, if you downloaded the Home Screen on Day 1 and an assignment on Day 4, both expire on Day 8.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),
              SizedBox(height: 10.h),
              Text(
                "While downloading, a grey tick appears next to the button. Once downloaded, it turns green.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),

              SizedBox(height: 25.h),
              _sectionHeader("Assignment Download Limit"),

              Text(
                "You can download a maximum of 7 assignments at a time. If you try to download an 8th, the app will prompt you to delete (by uploading) one of the existing ones first. You can re-download any assignment later without restriction.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),

              SizedBox(height: 25.h),
              _sectionHeader("Internet Connectivity & Uploads"),

              Text(
                "Stay connected to the internet as much as possible. Your attempted assignments are uploaded to the server only when online. Your CGPA improves only after the upload. If you stay offline for 7 consecutive days, the session will expire and you'll need internet to reopen the app.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),

              SizedBox(height: 25.h),
              _sectionHeader("Troubleshooting"),

              Text(
                "If assignments remain closed despite being opened by the teacher or you face a session timeout, use the RESET option from the menu. RESET deletes and re-downloads the Home Screen automatically every 7 days.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),
              SizedBox(height: 10.h),
              Text(
                "If scores are incorrect or assignments remain locked after RESET, use HARD RESET. This recalculates your scores from the beginning. For major issues, use TOUGH RESET, which rebuilds your entire account data.",
                style: TextStyle(fontSize: 10.sp, height: 1.5),
              ),

              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOUGH RESET Instructions:",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Send an SMS from your registered mobile number to 8800884167 as:",
                      style: TextStyle(fontSize: 10.sp, height: 1.5),
                    ),
                    SizedBox(height: 6.h),
                    SelectableText(
                      "ToughReset <EnrollmentNumber>",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Example: ToughReset 1234567890123",
                      style: TextStyle(fontSize: 10.sp, height: 1.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "After receiving confirmation SMS, perform a RESET in the app. Next TOUGH RESET can be done only after 24 hours.",
                      style: TextStyle(fontSize: 10.sp, height: 1.5),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                "If issues persist, contact your study center support team.",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: bronze,
        ),
      ),
    );
  }

  Widget _colorDescription(String colorName, String meaning) {
    final colorMap = {
      
      'Green': Color.fromARGB(255, 76, 119, 8),
      'Grey': Colors.grey,
      'Red': Colors.red.shade800,
      'Light Red': Colors.red.shade300,
      'Orange': Colors.orange,
      'Yellow': Colors.yellow.shade700,
      'Light Green': Colors.lightGreen,
      'Dark Green': Colors.green.shade700,
    };

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: colorMap[colorName],
              border: Border.all(color: Colors.black26),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              "$colorName Button — $meaning",
              style: TextStyle(fontSize: 10.sp, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
