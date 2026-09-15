// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/app.dart';
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';

import 'boorusama_test_runtime.dart';

Future<void> pumpBoorusamaCoreApp(
  WidgetTester tester, {
  BoorusamaRuntime? runtime,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    BoorusamaAppScope(
      runtime: runtime ?? createTestBoorusamaRuntime(),
      child: ProviderScope(
        overrides: overrides,
        child: const BoorusamaCoreApp(),
      ),
    ),
  );
  await tester.pump();
}
