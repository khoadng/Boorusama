// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/ddos/handler/providers.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/providers.dart';
import 'package:boorusama/core/http/cookies/providers.dart';
import 'package:boorusama/foundation/platform.dart';

import '../support/fakes/test_platform_services.dart';

void main() {
  test('Linux HTTP protection does not initialize a WebView plugin', () {
    final container = _container(platform: AppPlatform.linux);
    addTearDown(container.dispose);

    final handler = container.read(httpDdosProtectionBypassProvider);

    expect(handler.isDisabled, isFalse);
  });
}

ProviderContainer _container({required AppPlatform platform}) {
  return ProviderContainer(
    overrides: [
      appPlatformProvider.overrideWithValue(platform),
      appLoggerProvider.overrideWithValue(AppLogger()),
      cookieJarFactoryProvider.overrideWithValue(
        const MemoryCookieJarFactory(),
      ),
    ],
  );
}
