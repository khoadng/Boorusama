// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'webview_user_agent.dart';

final class PluginWebViewUserAgentService implements WebViewUserAgentService {
  const PluginWebViewUserAgentService();

  @override
  Future<String?> getUserAgent() => WebViewController().getUserAgent();
}
