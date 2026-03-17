import 'dart:io';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class RotationLock {
  static const MethodChannel _ch = MethodChannel('rotation_lock');

  static Future<bool?> isAutoRotateEnabled() async {
    if (!Platform.isAndroid) return null;
    try {
      final res = await _ch.invokeMethod('isAutoRotateEnabled');
      return res is bool ? res : null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<void> openDisplaySettings() async {
    if (!Platform.isAndroid) return;
    const intent = AndroidIntent(action: 'android.settings.DISPLAY_SETTINGS');
    await intent.launch();
  }
}
