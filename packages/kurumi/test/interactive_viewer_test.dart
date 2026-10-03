// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

// Android reports an 8px touch slop, which makes the page drag and the
// viewer's pan cross their thresholds within a single fast move event.
const _androidGestureSettings = DeviceGestureSettings(touchSlop: 8);

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(
      size: Size(400, 800),
      gestureSettings: _androidGestureSettings,
    ),
    child: child,
  ),
);

void main() {
  final axes = [
    (axis: Axis.vertical, step: const Offset(0, -1)),
    (axis: Axis.horizontal, step: const Offset(-1, 0)),
  ];

  for (final c in axes) {
    testWidgets(
      'a fast ${c.axis.name} flick on an unzoomed image turns the page',
      (tester) async {
        final pageController = PageController();
        addTearDown(pageController.dispose);

        await tester.pumpWidget(
          _wrap(
            PageView.builder(
              controller: pageController,
              scrollDirection: c.axis,
              itemCount: 3,
              itemBuilder: (_, _) => const KurumiInteractiveViewer(
                child: SizedBox.expand(),
              ),
            ),
          ),
        );

        final gesture = await tester.startGesture(const Offset(200, 400));
        await gesture.moveBy(
          c.step * 8,
          timeStamp: const Duration(milliseconds: 8),
        );
        await gesture.moveBy(
          c.step * 48,
          timeStamp: const Duration(milliseconds: 16),
        );
        await gesture.moveBy(
          c.step * 48,
          timeStamp: const Duration(milliseconds: 24),
        );
        await gesture.up(timeStamp: const Duration(milliseconds: 24));
        await tester.pumpAndSettle();

        expect(pageController.page, 1);
      },
    );
  }

  testWidgets('pinching an unzoomed image zooms in', (tester) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        KurumiInteractiveViewer(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );

    final first = await tester.startGesture(const Offset(150, 400));
    final second = await tester.startGesture(const Offset(250, 400));
    for (var i = 0; i < 10; i++) {
      await first.moveBy(const Offset(-10, 0));
      await second.moveBy(const Offset(10, 0));
      await tester.pump();
    }
    await first.up();
    await second.up();
    await tester.pumpAndSettle();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
  });

  testWidgets('dragging a zoomed image with one finger pans it', (
    tester,
  ) async {
    final controller = TransformationController(
      Matrix4.diagonal3Values(2, 2, 1),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        KurumiInteractiveViewer(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );

    final before = controller.value.getTranslation();
    await tester.dragFrom(const Offset(200, 400), const Offset(-100, -100));
    await tester.pumpAndSettle();

    expect(controller.value.getTranslation(), isNot(before));
  });
}
