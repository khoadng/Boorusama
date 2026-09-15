// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';

// Project imports:
import 'package:boorusama/core/settings/src/routes/settings_adaptive_page.dart';

void main() {
  testWidgets('updates the installed route reverse duration', (tester) async {
    var animate = false;
    var showDetail = true;
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Navigator(
              pages: [
                const SettingsAdaptivePage<void>(
                  key: ValueKey('root'),
                  animate: false,
                  child: Scaffold(body: Text('Root')),
                ),
                if (showDetail)
                  SettingsAdaptivePage<void>(
                    key: const ValueKey('detail'),
                    animate: animate,
                    child: const Scaffold(body: Text('Detail')),
                  ),
              ],
              onDidRemovePage: (_) {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    rebuild(() => animate = true);
    await tester.pump();
    rebuild(() => showDetail = false);
    await tester.pump();

    expect(find.text('Detail'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Detail'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Detail'), findsNothing);
  });

  testWidgets('supports an interactive edge-swipe pop', (tester) async {
    var showDetail = true;
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Navigator(
              pages: [
                const SettingsAdaptivePage<void>(
                  key: ValueKey('root'),
                  animate: true,
                  child: Scaffold(body: Text('Root')),
                ),
                if (showDetail)
                  const SettingsAdaptivePage<void>(
                    key: ValueKey('detail'),
                    animate: true,
                    child: Scaffold(body: Text('Detail')),
                  ),
              ],
              onDidRemovePage: (page) {
                if (page.key == const ValueKey('detail') && showDetail) {
                  rebuild(() => showDetail = false);
                }
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragFrom(
      const Offset(1, 300),
      const Offset(600, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsNothing);
    expect(find.text('Root'), findsOneWidget);
  });
}
