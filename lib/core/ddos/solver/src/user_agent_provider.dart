// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

abstract class UserAgentProvider {
  Future<String?> getUserAgent();
}

class WebViewUserAgentProvider implements UserAgentProvider {
  WebViewUserAgentProvider({this.onUserAgent});

  final void Function(String?)? onUserAgent;
  String? _userAgent;

  @override
  Future<String?> getUserAgent() async {
    if (_userAgent != null) {
      return _userAgent;
    }

    _userAgent ??= await WebViewController().getUserAgent();

    onUserAgent?.call(_userAgent);
    return _userAgent;
  }
}
