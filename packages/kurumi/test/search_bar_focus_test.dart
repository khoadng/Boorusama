// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

void main() {
  testWidgets(
    'the focus ring outlines the whole search bar, leading icon included',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => KurumiTheme(
            data: KurumiThemeData.fromMaterial(Theme.of(context)),
            child: child!,
          ),
          home: KurumiFocusRing(
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 48,
                  child: KurumiSearchBar(
                    enabled: false,
                    onTap: () {},
                    leading: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump();

      final bar = tester.getRect(find.byType(KurumiSearchBar));
      expect(
        find.byType(KurumiFocusRing),
        paints..drrect(
          outer: RRect.fromRectAndRadius(
            bar.inflate(5),
            const Radius.circular(10),
          ),
        ),
      );
    },
  );
}
