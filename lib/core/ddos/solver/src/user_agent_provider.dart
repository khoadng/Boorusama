// Project imports:
import '../../../../foundation/webview_user_agent.dart';

abstract class UserAgentProvider {
  Future<String?> getUserAgent();
}

class WebViewUserAgentProvider implements UserAgentProvider {
  WebViewUserAgentProvider({
    required this.service,
    this.onUserAgent,
  });

  final WebViewUserAgentService service;
  final void Function(String?)? onUserAgent;
  String? _userAgent;

  @override
  Future<String?> getUserAgent() async {
    if (_userAgent != null) {
      return _userAgent;
    }

    _userAgent ??= await service.getUserAgent();

    onUserAgent?.call(_userAgent);
    return _userAgent;
  }
}
