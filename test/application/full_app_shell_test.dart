// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/announcements/providers.dart';
import 'package:boorusama/core/app.dart';
import 'package:boorusama/core/app_external_effects.dart';
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/home/src/widgets/booru_scope.dart';

import 'support/fake_booru_backend.dart';

void main() {
  testWidgets(
    'boots the complete post-bootstrap application shell headlessly',
    (tester) async {
      final backend = FakeBooruBackend();

      await tester.pumpWidget(
        BoorusamaAppScope(
          runtime: backend.createRuntime(),
          additionalOverrides: [
            appAnnouncementsProvider.overrideWith(
              (ref) => const <AppAnnouncement>[],
            ),
          ],
          child: const BoorusamaExternalEffects(
            child: BoorusamaCoreApp(),
          ),
        ),
      );

      try {
        for (var i = 0; i < 20; i++) {
          if (find.byType(BooruScope).evaluate().isNotEmpty) break;
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(BooruScope), findsOneWidget);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }
    },
  );
}
