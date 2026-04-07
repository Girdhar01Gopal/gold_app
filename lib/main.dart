import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:gold_app/utils/landscape_only_gate.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gold_app/oflinerepo/questionhivemodel.dart';
import 'package:gold_app/utils/localStorage/hivemodel.dart';

import 'infrastructure/routes/admin_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await GetStorage.init();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HivemodelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(hivequestionAdapter());
  }

  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      appBarTheme: const AppBarTheme(color: Colors.blue),
    );

    final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.black,
      appBarTheme: const AppBarTheme(color: Colors.black),
    );

    return ScreenUtilInit(
      splitScreenMode: false,
      minTextAdapt: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'Abhyasa',
          debugShowCheckedModeBanner: false,
          getPages: AdminRoutes.routes,
          initialRoute: AdminRoutes.ADMIN_SPLASH,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,

          // ✅ Gate ENTIRE app here
          builder: (context, child) {
            return LandscapeOnlyGate(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}
