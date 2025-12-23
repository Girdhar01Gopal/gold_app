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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1), // Assignment primary color
                  Color(0xFF4CA1AF), // Assignment accent color
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(top: 50.h, bottom: 24.h, left: 20.w, right: 20.w),
            child: Column(
              children: [
                // Profile Circle
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                // Student Info
                Obx(() => Text(
                  studentname.value.replaceAll('"', '').trim(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                SizedBox(height: 4.h),
                Obx(() => Text(
                  '${className.value.replaceAll('"', '').trim()} • ${session.value.replaceAll('"', '').replaceAll('-', '-').trim()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                SizedBox(height: 4.h),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    enrollmentNo.value.replaceAll('"', '').trim(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
              ],
            ),
          ),

          // ---------- Drawer Items ----------
          Expanded(
            child: Container(
              color: Color(0xFFF5F6FA),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                child: Column(
                  children: [
                    _drawerItem(
                      title: "Dashboard",
                      icon: Icons.home_rounded,
                      route: AdminRoutes.homeScreen,
                      currentRoute: currentRoute,
                    ),
                    // _drawerItem(
                    //   title: "Usage",
                    //   icon: Icons.insert_chart_outlined_rounded,
                    //   route: AdminRoutes.usageScreen,
                    //   currentRoute: currentRoute,
                    // ),
                    _drawerItem(
                      title: "Reset System",
                      icon: Icons.settings_backup_restore_rounded,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF4CA1AF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
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
    final primaryColor = Color(0xFF0D47A1);
    final accentColor = Color(0xFF4CA1AF);

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: primaryColor.withOpacity(0.2)) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (onTap != null) {
                await onTap();
                return;
              }

              if (title == "Reset System") {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      "Confirm Reset",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    content: Text("Are you ready to reset the application?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("No",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          GetStorage().erase();
                          Navigator.pop(context, true);
                          Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
                        },
                        child: Text("Yes",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else if (!isSelected) {
                Get.offAllNamed(route);
              } else {
                Get.back();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [primaryColor, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : (isHovered ? primaryColor.withOpacity(0.1) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : (isHovered ? primaryColor : Colors.grey.shade600),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isSelected ? primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: primaryColor,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
