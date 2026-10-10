// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a like button can be focused and toggled from the keyboard', (
    tester,
  ) async {
    final taps = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: KurumiLikeButton(
            isLiked: false,
            onTap: (isLiked) async {
              taps.add(isLiked);
              return !isLiked;
            },
            builder: (_) => const Icon(Icons.bookmark),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(taps, [false]);
  });
}
