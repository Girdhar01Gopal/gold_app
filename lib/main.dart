import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart'; 

import 'infrastructure/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await GetStorage.init(); // Initialize GetStorage for local cache

  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
  

    return ScreenUtilInit(
      splitScreenMode: false,
      minTextAdapt: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Maharishi Learn',
          debugShowCheckedModeBanner: false,
          getPages: AdminRoutes.routes,
          initialRoute: AdminRoutes.ADMIN_SPLASH, // Same route for now
           theme: ThemeData(useMaterial3: true), // Auto switch based on system theme
        );
      },
    );
  }
}
