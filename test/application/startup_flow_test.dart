// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/home/src/widgets/booru_scope.dart';
import 'package:boorusama/core/settings/src/pages/settings_page.dart';

import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'starts from the test runtime and navigates between primary screens',
    (tester) async {
      final harness = HeadlessAppHarness();
      addTearDown(() => harness.teardown(tester));

      await harness.pump(tester);
      await harness.settle(tester);

      expect(find.byType(BooruScope), findsOneWidget);

      final settingsIcon = find.byIcon(Symbols.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.last);
      } else {
        await tester.tap(find.byIcon(Symbols.menu).first);
        await tester.pump();
        await harness.settle(tester);
        await tester.tap(find.text('Settings').last);
      }
      await tester.pump();
      await harness.settle(tester);

      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.pageBack();
      await tester.pump();
      await harness.settle(tester);

      expect(find.byType(BooruScope), findsOneWidget);
    },
  );
}
