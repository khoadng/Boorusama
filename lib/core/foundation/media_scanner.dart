// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';

class MediaScanner {
  static const MethodChannel _channel = MethodChannel('media_scanner');

  static Future<String?> loadMedia({String? path}) async =>
      _channel.invokeMethod('refreshGallery', {'path': path});
}
