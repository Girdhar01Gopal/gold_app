import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:gold_app/utils/localStorage/hivemodel.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; 

import 'infrastructure/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
 await Hive.initFlutter();

  Hive.registerAdapter(HivemodelAdapter());
  await GetStorage.init(); // Initialize GetStorage for local cache

  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
   final ThemeData lightTheme = ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      appBarTheme: AppBarTheme(color: Colors.blue),
    );

    final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.grey[600],
      appBarTheme: AppBarTheme(color: Colors.grey[900]!),
    );

    return ScreenUtilInit(
      splitScreenMode: false,
      minTextAdapt: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Maharishi Learn',
          debugShowCheckedModeBanner: false,
          getPages: AdminRoutes.routes,
           theme: lightTheme,
          darkTheme: darkTheme,
          initialRoute: AdminRoutes.ADMIN_SPLASH, // Same route for now
           themeMode: ThemeMode.system, // Auto switch based on system theme
        );
      },
    );
  }
}
