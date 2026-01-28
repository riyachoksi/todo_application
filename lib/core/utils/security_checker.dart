import 'package:flutter_jailbreak_detection_plus/flutter_jailbreak_detection_plus.dart';
import '../error/exceptions.dart';

class SecurityChecker {
  Future<void> checkDeviceSecurity() async {
    try {
      final isJailbroken = await FlutterJailbreakDetectionPlus.jailbroken;

      if (isJailbroken) {
        throw SecurityException(
          'This app cannot run on rooted or jailbroken devices for security reasons.',
          code: 'DEVICE_COMPROMISED',
        );
      }
    } catch (e) {
      if (e is SecurityException) {
        rethrow;
      }
    }
  }

  Future<bool> isDeviceSecure() async {
    try {
      final isJailbroken = await FlutterJailbreakDetectionPlus.jailbroken;
      return !isJailbroken;
    } catch (e) {
      return true;
    }
  }
}
