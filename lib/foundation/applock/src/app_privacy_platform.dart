// Flutter imports:
import 'package:flutter/services.dart';

class AppPrivacyPlatform {
  const AppPrivacyPlatform._();

  static const _channel = MethodChannel('app_privacy');

  static Future<void> setPrivacyCoverEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod<void>(
        'setPrivacyCoverEnabled',
        {'enabled': enabled},
      );
    } on MissingPluginException {
      // Unsupported platforms use the Flutter privacy cover only.
    }
  }
}
