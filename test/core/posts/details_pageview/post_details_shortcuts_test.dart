// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/material.dart';

// Project imports:
import 'package:boorusama/core/posts/details_pageview/src/post_details_shortcuts.dart';
import 'package:boorusama/core/posts/details_pageview/widgets.dart';

void main() {
  testWidgets(
    'down from the page lands on the lowest control in view, not one '
    'scrolled far down a side panel',
    (tester) async {
      tester.view.physicalSize = const Size(960, 540);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = PostDetailsPageViewController(
        initialPage: 0,
        totalPage: 1,
        checkIfLargeScreen: () => true,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostDetailsShortcuts(
              controller: controller,
              useVerticalLayout: false,
              isLargeScreen: true,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Pause'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 360,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text('Tag'),
                          ),
                          const SizedBox(height: 1500),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Customize'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(
        Focus.of(tester.element(find.text('Pause'))).hasPrimaryFocus,
        isTrue,
      );
    },
  );
}
