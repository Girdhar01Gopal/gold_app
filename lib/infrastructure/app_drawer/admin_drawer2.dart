// infrastructure/app_drawer/admin_drawer2.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../infrastructure/routes/admin_routes.dart';
import '../../utils/constants/color_constants.dart';

class AdminDrawer2 extends StatefulWidget {
  @override
  _AdminDrawer2State createState() => _AdminDrawer2State();
}

class _AdminDrawer2State extends State<AdminDrawer2> {
  String? hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ==== Drawer Header ====
            Container(
              height: 340.h,
              width: 150.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9B1313), Color(0xFF4a4a4a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    right: -60,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.school, size: 200, color: Colors.white),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/images/avatar.png'),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "GIRDHAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        "ENO: 12345678909",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 7.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ==== Menu Items ====
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionTitle("GENERAL"),
                  _buildDrawerItem(
                    title: "Usage",
                    icon: Icons.insert_chart_outlined,
                    route: AdminRoutes.usageScreen,
                    currentRoute: currentRoute,
                  ),
                  // _buildDrawerItem(
                  //   title: "File Manager",
                  //   icon: Icons.folder_open_rounded,
                  //   route: AdminRoutes.LOADING_SCREEN,
                  //   currentRoute: currentRoute,
                  // ),
                  _buildDrawerItem(
                    title: "Discussion List",
                    icon: Icons.forum_outlined,
                    route: AdminRoutes.LOADING_SCREEN,
                    currentRoute: currentRoute,
                  ),
                  _buildSectionDivider(),

                  _buildSectionTitle("ADMIN ACTIONS"),
                  _buildDrawerItem(
                    title: "Change Academic Year",
                    icon: Icons.date_range_outlined,
                    route: AdminRoutes.LOADING_SCREEN,
                    currentRoute: currentRoute,
                  ),
                  _buildDrawerItem(
                    title: "Assignment Reset",
                    icon: Icons.restore_page_outlined,
                    route: AdminRoutes.LOADING_SCREEN,
                    currentRoute: currentRoute,
                  ),
                  _buildDrawerItem(
                    title: "Refresh Test CGPA",
                    icon: Icons.trending_up_rounded,
                    route: AdminRoutes.LOADING_SCREEN,
                    onTap: () =>Get.dialog(
  AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    title: const Text('Refresh CGPA'),
    content: const Text('Are you sure you want to refresh the Test CGPA?'),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.APP_Color_Indigo,
        ),
        onPressed: () async {
          Get.back(); // Close confirmation dialog first

          // Show loading dialog
          Get.dialog(
            Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                  
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
            barrierColor: Colors.black54,
          );

          // Simulate process (replace with actual API call if needed)
          await Future.delayed(const Duration(seconds: 2));

          // Close the loading dialog
          Get.back();

          // Show success dialog
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Success'),
                ],
              ),
              content: const Text(
                'Test CGPA has been successfully refreshed.',
                style: TextStyle(height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.indigo),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Text(
          'Refresh',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  ),
),


                    currentRoute: currentRoute,
                  ),
                  _buildSectionDivider(),

                  _buildDrawerItem(
                    title: "Reset System",
                    icon: Icons.settings_backup_restore,
                    route: AdminRoutes.LOADING_SCREEN,
                    currentRoute: currentRoute,
                    color: Color(0xFF4a4a4a),
                  ),
                ],
              ),
            ),

            /// ==== Logout Section ====
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showLogoutDialog,
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 10.w),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required String route,
    required String currentRoute,
    VoidCallback? onTap,
    Color? color,
  }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isSelected
            ? AppColor.grey_200
            : isHovered
                ? AppColor.grey_100
                : Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: isSelected
                ? AppColor.APP_Color_Indigo
                : color ?? Colors.black87,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColor.APP_Color_Indigo
                  : color ?? Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 9.sp,
            ),
          ),
          onTap: () {
            if (onTap != null) {
              onTap();
              return;
            }
            if (!isSelected) {
              Get.toNamed(route);
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }
  }

  /// ==== Section Title ====
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// ==== Divider ====
  Widget _buildSectionDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Divider(color: Colors.grey.shade300, thickness: 0.8),
    );
  }

  /// ==== Logout Dialog ====
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.APP_Color_Indigo,
            ),
            onPressed: () {
              GetStorage().erase();
              Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

