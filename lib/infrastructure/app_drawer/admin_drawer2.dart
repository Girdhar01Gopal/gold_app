import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gold_app/localstorage.dart';
import 'package:gold_app/prefconst.dart';
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
    enrollmentNo.value = await PrefManager().readValue(
      key: PrefConst.EnrollmentNo,
    );
    studentname.value = await PrefManager().readValue(
      key: PrefConst.studentname,
    );
    className.value = await PrefManager().readValue(key: PrefConst.className);
    session.value = await PrefManager().readValue(key: PrefConst.session);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final s = (size.width / 1200).clamp(0.85, 1.15);
    final drawerWidth = (size.width * 0.24).clamp(250.0, 340.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        elevation: 5,
        backgroundColor: isDarkMode ? const Color(0xFF101218) : Colors.white,
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
              padding: EdgeInsets.only(
                top: (22 * s) + MediaQuery.of(context).padding.top,
                bottom: 18 * s,
                left: 18 * s,
                right: 18 * s,
              ),
              child: Column(
                children: [
                  // Profile Circle
                  Container(
                    width: 56 * s,
                    height: 56 * s,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 26 * s,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10 * s),
                  // Student Info
                  Obx(
                    () => Text(
                      studentname.value.replaceAll('"', '').trim(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4 * s),
                  Obx(
                    () => Text(
                      '${className.value.replaceAll('"', '').trim()} • ${session.value.replaceAll('"', '').replaceAll('-', '-').trim()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * s,
                        vertical: 4 * s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        enrollmentNo.value.replaceAll('"', '').trim(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Drawer Items ----------
            Expanded(
              child: Container(
                color: isDarkMode
                    ? const Color(0xFF161A22)
                    : const Color(0xFFF5F6FA),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: 14 * s,
                    horizontal: 12 * s,
                  ),
                  child: Column(
                    children: [
                      _drawerItem(
                        title: "Dashboard",
                        icon: Icons.home_rounded,
                        route: AdminRoutes.homeScreen,
                        currentRoute: currentRoute,
                        isDarkMode: isDarkMode,
                      ),
                      _drawerItem(
                        title: "Reset System",
                        icon: Icons.settings_backup_restore_rounded,
                        route: AdminRoutes.LOADING_SCREEN,
                        currentRoute: currentRoute,
                        isDarkMode: isDarkMode,
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
                  colors: [Color(0xFF0D47A1), Color(0xFF4CA1AF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 14 * s,
                horizontal: 16 * s,
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  "© MGEPL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required String title,
    required IconData icon,
    required String route,
    required String currentRoute,
    bool isLogout = false,
    bool isDarkMode = false,
    Future<void> Function()? onTap,
  }) {
    final isSelected = currentRoute == route;
    final isHovered = hoveredRoute == route;
    final primaryColor = const Color(0xFF0D47A1);
    final accentColor = const Color(0xFF4CA1AF);
    final s = (MediaQuery.of(context).size.width / 1200).clamp(0.85, 1.15);

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredRoute = route),
      onExit: (_) => setState(() => hoveredRoute = null),
      child: Container(
        margin: EdgeInsets.only(bottom: 8 * s),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: primaryColor.withOpacity(0.2))
              : null,
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
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF101218)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                        child: Text("No", style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          GetStorage().erase();
                          Navigator.pop(context, true);
                          Get.offAllNamed(AdminRoutes.login);
                        },
                        child: Text("Yes", style: TextStyle(color: Colors.red)),
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
              padding: EdgeInsets.symmetric(
                horizontal: 14 * s,
                vertical: 12 * s,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40 * s,
                    height: 40 * s,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [primaryColor, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isHovered
                                ? primaryColor.withOpacity(0.1)
                                : (isDarkMode
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.grey.shade100)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : (isHovered
                                ? primaryColor
                                : (isDarkMode
                                      ? Colors.white70
                                      : Colors.grey.shade600)),
                      size: 21 * s,
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14 * s,
                        color: isSelected
                            ? primaryColor
                            : (isDarkMode ? Colors.white : Colors.black87),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: primaryColor,
                      size: 14 * s,
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
