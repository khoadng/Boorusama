// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

abstract class UserAgentProvider {
  Future<String?> getUserAgent();
}

class WebViewUserAgentProvider implements UserAgentProvider {
  String? _userAgent;

  @override
  Future<String?> getUserAgent() async {
    if (_userAgent != null) {
      return _userAgent;
    }

    // ignore: join_return_with_assignment
    _userAgent ??= await WebViewController().getUserAgent();

    return _userAgent;
  }
}
