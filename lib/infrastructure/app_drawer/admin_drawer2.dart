import 'dart:io'; // For exit(0)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
import 'package:gold_app/utils/constants/color_constants.dart';
import '../../infrastructure/routes/admin_routes.dart';

class AdminDrawer2 extends StatefulWidget {
  const AdminDrawer2({super.key});

  @override
  _AdminDrawer2State createState() => _AdminDrawer2State();
}

class _AdminDrawer2State extends State<AdminDrawer2> {
  String? hoveredRoute;
  var studentname = ''.obs;
  var className = ''.obs;
  var session = ''.obs;
  var enrollmentNo = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    enrollmentNo.value = await PrefManager().readValue(key: PrefConst.EnrollmentNo);
    studentname.value = await PrefManager().readValue(key: PrefConst.studentname);
    className.value = await PrefManager().readValue(key: PrefConst.className);
    session.value = await PrefManager().readValue(key: PrefConst.session);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;



    return Drawer(
      elevation: 4,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ---------- Header Section ----------
          CustomPaint(
            painter: DrawerHeaderPainter(),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.22, // Adjusted height
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
              child: Row(children: [
                CircleAvatar(
                    radius: MediaQuery.sizeOf(context).width * 0.09, // Dynamic width
                    backgroundColor: Colors.white,
                    child: Icon(CupertinoIcons.person, size: 38.sp, color: AppColor.MAHARISHI_BRONZE),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Obx(()=> Text(
                      '${studentname.value.replaceAll('"','').trim()}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                        Obx(()=> Text(
                    '${className.value.replaceAll('"','').trim()} (AY ${session.value.replaceAll('"','').replaceAll('-', ' - ').trim()})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                      Obx(()=> Text(
                    '${enrollmentNo.value.replaceAll('"','').trim()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  
                ],
              ),
              ],)
            ),
          ),

          // ---------- Drawer Items ----------
          Expanded(
            child: Container(
              // 🔹 Background Image
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/FIITJEE_Logo.png"), // Your background image
                  fit: BoxFit.cover,
                  opacity: 0.1, // Soft visibility (adjust 0.1–0.4 as desired)
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFf9f3f2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              // 🔹 Drawer Scrollable Content
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  children: [
                    _drawerItem(
                      title: "Dashboard",
                      icon: Icons.home_outlined,
                      route: AdminRoutes.homeScreen,
                      currentRoute: currentRoute,
                    ),
                    _drawerItem(
                      title: "Usage",
                      icon: Icons.insert_chart_outlined,
                      route: AdminRoutes.usageScreen,
                      currentRoute: currentRoute,
                    ),
                    // _drawerItem(
                    //   title: "Change Academic Year",
                    //   icon: Icons.date_range_outlined,
                    //   route: AdminRoutes.LOADING_SCREEN,
                    //   currentRoute: currentRoute,
                    // ),
                    _drawerItem(
                      title: "Reset System",
                      icon: Icons.settings_backup_restore,
                      route: AdminRoutes.LOADING_SCREEN,
                      currentRoute: currentRoute,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------- Footer ----------
          Container(
            color: AppColor.MAHARISHI_BRONZE,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            width: double.infinity,
            child: Center(
              child: Text(
                "© MGEPL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData icon,
    required String route,
    required String currentRoute,
    bool isLogout = false,
    Future<void> Function()? onTap,
  }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: InkWell(
        onTap: () async {
          // If a custom onTap is provided, execute it and skip default navigation.
          if (onTap != null) {
            await onTap();
            return;
          }

          if (title == "Reset") {
            bool confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                title: const Text(
                  "Confirm Reset",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.MAHARISHI_BRONZE,
                  ),
                ),
                content: const Text("Are you ready to reset the application?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("No",
                        style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () async {
                      //await PrefManager().clearPref();
                    },
                    child: const Text("Yes",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              GetStorage().erase();
              Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
            }
          } else if (!isSelected) {
            Get.offAllNamed(route);
          } else {
            Get.back();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.MAHARISHI_BRONZE.withOpacity(0.08)
                : isHovered
                    ? Colors.grey[100]
                    : Colors.transparent,
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: AppColor.MAHARISHI_BRONZE,
                      width: 4.w,
                    ),
                  )
                : null,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : isSelected
                      ? AppColor.MAHARISHI_BRONZE
                      : isHovered
                          ? Colors.black87
                          : Colors.black54,
              size: 24.sp,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                color: isLogout
                    ? Colors.red
                    : isSelected
                        ? AppColor.MAHARISHI_BRONZE
                        : Colors.black87,
                fontWeight:
                    isLogout || isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();

    final gradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 231, 217, 20), // bright gold
        Color(0xFFEB8A2A), // soft amber
        Color(0xFFB8860B),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
