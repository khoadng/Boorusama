import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';

import 'package:boorusama/core/configs/auth/src/pages/cookie_access_webview_page.dart';
import 'package:boorusama/core/debug/src/logging/app_logger.dart';
import 'package:boorusama/foundation/browser/providers.dart';
import 'package:boorusama/foundation/browser/types.dart';
import 'package:boorusama/foundation/loggers.dart';

import '../support/fake_embedded_browser.dart';

void main() {
  testWidgets('exports native browser cookies through the existing callback', (
    tester,
  ) async {
    final session = FakeEmbeddedBrowserSession();
    final uri = Uri.parse('https://example.com/login');
    session.cookiesByUri[uri] = [
      const BrowserCookie(
        name: 'user_id',
        value: 'placeholder',
        domain: 'example.com',
        path: '/',
      ),
    ];
    final factory = FakeEmbeddedBrowserFactory(sessions: [session]);
    List<dynamic>? exported;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          embeddedBrowserFactoryProvider.overrideWithValue(factory),
          loggerProvider.overrideWithValue(AppLogger()),
        ],
        child: MaterialApp(
          home: CookieAccessWebViewPage(
            url: uri.toString(),
            onGet: (cookies) => exported = cookies,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Access Cookie'));
    await tester.pumpAndSettle();

    expect(exported, isNotNull);
    expect(exported!.single.name, 'user_id');
    expect(exported!.single.value, 'placeholder');
  });
}
