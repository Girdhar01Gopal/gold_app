// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart'; // ✅ For orientation control
import 'infrastructure/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await GetStorage.init(); // Initialize GetStorage for local cache
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = box.read('isLoggedIn') ?? false;

    return ScreenUtilInit(
      designSize: const Size(411.42, 890.28),
      minTextAdapt: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Gold App',
          debugShowCheckedModeBanner: false,
          getPages: AdminRoutes.routes,
          initialRoute: isLoggedIn
              ? AdminRoutes.ADMIN_SPLASH
              : AdminRoutes.ADMIN_SPLASH, // same route for now
          theme: ThemeData(useMaterial3: true),
        );
      },
    );
  }
}
