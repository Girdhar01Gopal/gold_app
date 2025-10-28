import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../infrastructure/routes/admin_routes.dart';
import '../../utils/constants/color_constants.dart';

class AdminDrawer extends StatefulWidget {
  @override
  _AdminDrawerState createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String? hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white, // Set the background color of the drawer items
        child: Column(
          children: [
            // Drawer Header with black background
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black, // Set the background color of the drawer header to black
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enrolment number', // Text in small letters
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Removed image and replaced with tex
                  Text(
                    '123456789009', // Text in bold with the enrollment number
                    style: TextStyle(
                      color:Colors.yellow[800],
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem("Reset", Icons.reset_tv, AdminRoutes.LOADING_SCREEN, currentRoute),
                    _buildDivider(),
                    _buildDrawerItem("Discussion List", Icons.view_list, AdminRoutes.LOADING_SCREEN, currentRoute),
                    _buildDivider(),
                    _buildDrawerItem("Reupload result", Icons.upload, AdminRoutes.LOADING_SCREEN, currentRoute),
                    _buildDivider(),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      String title,
      IconData icon,
      String route,
      String currentRoute, {
        bool isLogout = false,
      }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: Container(
        color: isSelected
            ? AppColor.grey_200
            : isHovered
            ? AppColor.grey_100
            : null,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            icon,
            color: isLogout
                ? Colors.red
                : isSelected
                ? AppColor.APP_Color_Indigo
                : isHovered
                ? AppColor.APP_Color_Pink
                : Colors.yellow[800],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout
                  ? Colors.red
                  : isSelected
                  ? AppColor.APP_Color_Indigo
                  : isHovered
                  ? AppColor.APP_Color_Pink
                  : Colors.black, // Keeping text color white
              fontWeight: isLogout || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (isLogout) {
              GetStorage().erase();
              Get.offAllNamed(AdminRoutes.LOADING_SCREEN);
            } else if (!isSelected) {
              Get.toNamed(route);
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 3.h, // Increased height for a bolder line
        width: double.infinity, // Full width divider
        color: Colors.grey[800],
      ),
    );
  }
}
