import 'package:coreutils/coreutils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boorusama/core/ddos/solver/src/user_agent_provider.dart';
import 'package:boorusama/core/http/cookies/providers.dart';
import 'package:boorusama/foundation/webview_user_agent.dart';

void main() {
  test('user-agent provider caches the injected service result', () async {
    final service = _RecordingUserAgentService('HeadlessWebView/1.0');
    final provider = WebViewUserAgentProvider(service: service);

    expect(await provider.getUserAgent(), 'HeadlessWebView/1.0');
    expect(await provider.getUserAgent(), 'HeadlessWebView/1.0');
    expect(service.calls, 1);
  });

  test('cookie jar creation stays lazy behind its factory', () async {
    final factory = _RecordingCookieJarFactory();
    final container = ProviderContainer(
      overrides: [cookieJarFactoryProvider.overrideWithValue(factory)],
    );

    final lazyJar = container.read(cookieJarProvider);
    expect(factory.created, 0);
    await lazyJar();
    expect(factory.created, 1);

    container.dispose();
  });
}

final class _RecordingUserAgentService implements WebViewUserAgentService {
  _RecordingUserAgentService(this.value);

  final String value;
  var calls = 0;

  @override
  Future<String?> getUserAgent() async {
    calls++;
    return value;
  }
}

final class _RecordingCookieJarFactory implements CookieJarFactory {
  var created = 0;

  @override
  Future<CookieJar> create() async {
    created++;
    return CookieJar();
  }
}
