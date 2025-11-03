// infrastructure/routes/admin_routes.dart
import 'package:get/get.dart';
import 'package:gold_app/bindings/mathscreenbinding.dart';
import 'package:gold_app/bindings/physicsbinding.dart';
import 'package:gold_app/bindings/testscreenbinding.dart';
import 'package:gold_app/screens/mathscreen.dart';
import 'package:gold_app/screens/physicsscreen.dart';
import 'package:gold_app/screens/testscreenview.dart';
import '../../bindings/Loading_Binding.dart';
import '../../bindings/MainScreenBinding.dart';
import '../../bindings/bindings.dart';
import '../../bindings/dashboard_binding.dart';
import '../../bindings/continue_screen_binding.dart'; // Import the new binding
import '../../screens/ContinueScreen.dart';
import '../../screens/Loading_Screen.dart';
import '../../screens/MainScreen.dart';
import '../../screens/admin_splash_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/usage_screen.dart';

class AdminRoutes {
  // ==================
  // Route Names
  // ==================
  static const ADMIN_SPLASH = '/admin/splash';
  static const LOADING_SCREEN = '/loading';
  static const homeScreen = '/home';
  static const MAIN_SCREEN = '/mainScreen';
  static const CONTINUE_SCREEN = '/continue';
  static const usageScreen = '/usageScreen';
    static const mathscreen = '/mathscreen';
        static const physics = '/physics';
          static const testscreen = '/testscreen';




  // ========
  // Route Definitions
  // ========
  static final List<GetPage> routes = [
    // Splash Screen
    GetPage(
      name: ADMIN_SPLASH,
      page: () => AdminSplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 400),
    ),
 GetPage(
      name: testscreen,
      page: () =>  Testscreenview(),
      binding: Testscreenbinding(),
    ),
    GetPage(
      name: mathscreen,
      page: () => Mathscreen(),
       binding: Mathscreenbinding(),
    ),
    GetPage(
      name: physics,
      page: () => Physicsscreen(),
       binding: Physicsbinding(),
    ),

    // Loading Screen
    GetPage(
      name: LOADING_SCREEN,
      page: () => LoadingScreen(),
      binding: LoadingBinding(),
    ),

    // Home Screen
    GetPage(
      name: homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),

    // Main Screen
    GetPage(
      name: MAIN_SCREEN,
      page: () => MainScreen(),
      binding: MainScreenBinding(),
    ),

    // Continue Screen
    GetPage(
      name: CONTINUE_SCREEN,
      page: () => ContinueScreen(), // New screen to display
      binding: ContinueScreenBinding(), // Binding for ContinueScreen
    ),
    GetPage(
      name: usageScreen,
      page: () => UsageScreen(),
      binding: UsageBinding(),
    ),
  ];
}
