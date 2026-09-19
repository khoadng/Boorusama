// Project imports:
import 'browser/types.dart';
import 'webview_user_agent.dart';

final class PluginWebViewUserAgentService implements WebViewUserAgentService {
  const PluginWebViewUserAgentService({required this.factory});

  final EmbeddedBrowserFactory factory;

  @override
  Future<String?> getUserAgent() => factory.getDefaultUserAgent();
}
