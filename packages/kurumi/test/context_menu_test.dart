// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

typedef _Item = ({String label, bool destructive});

Widget _menu({
  required List<_Item> items,
  required void Function(String label) onSelected,
  required Widget child,
  KurumiContextMenuController? controller,
  bool triggers = true,
}) => KurumiContextMenu(
  controller: controller,
  triggers: triggers,
  menuItemsBuilder: (context) => [
    for (final item in items)
      KurumiContextMenuTile(
        title: item.label,
        destructive: item.destructive,
        onTap: () => onSelected(item.label),
      ),
  ],
  child: child,
);

const _screen = Size(400, 400);

final class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  final selected = <String>[];
  final haptics = <String>[];

  static List<_Item> itemsFor(String target) => [
    (label: '$target copy', destructive: false),
    (label: '$target search', destructive: false),
    (label: '$target delete', destructive: true),
  ];

  Future<void> mount({
    KurumiContextMenuController? controller,
    bool triggers = true,
    VoidCallback? onChildLongPress,
    Map<String, Offset> targets = const {
      'A': Offset(20, 20),
      'B': Offset(280, 20),
    },
  }) async {
    tester.view.physicalSize = _screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final page = Scaffold(
      body: Stack(
        children: [
          for (final MapEntry(key: name, value: offset) in targets.entries)
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: _menu(
                items: itemsFor(name),
                onSelected: selected.add,
                controller: name == 'A' ? controller : null,
                triggers: triggers,
                child: InkWell(
                  onTap: () {},
                  onLongPress: onChildLongPress,
                  child: SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(child: Text(name)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => KurumiTheme(
          data: KurumiThemeData.fromMaterial(Theme.of(context)),
          behavior: const KurumiBehaviorData(
            contextMenuShowFeedback: HapticFeedback.selectionClick,
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => page)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  // An open menu's backdrop covers the screen, so a right-click elsewhere
  // lands on it rather than on the target.
  Future<void> rightClick(String target) async {
    await tester.tap(
      find.text(target),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
  }

  Future<void> longPress(String target) async {
    await tester.longPress(find.text(target));
    await tester.pumpAndSettle();
  }

  bool isOpen(String target) => find.text('$target copy').evaluate().isNotEmpty;

  Future<void> focus(String target) async {
    Focus.of(tester.element(find.text(target))).requestFocus();
    await tester.pumpAndSettle();
  }

  /// Whether the focused control is the one labelled [label].
  bool isFocusOn(String label) {
    final focused = FocusManager.instance.primaryFocus?.context;
    final text = find.text(label).evaluate().firstOrNull;
    if (focused == null || text == null) return false;
    var inside = false;
    text.visitAncestorElements((ancestor) {
      inside = ancestor == focused;
      return !inside;
    });
    return inside;
  }

  /// Rects of the menu items, which must all be on screen to be usable.
  List<Rect> itemRects(String target) => [
    for (final item in itemsFor(target))
      tester.getRect(
        find
            .ancestor(
              of: find.text(item.label),
              matching: find.byType(InkWell),
            )
            .first,
      ),
  ];
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.macOS);
  final mobile = TargetPlatformVariant.only(TargetPlatform.iOS);

  for (final (name, variant) in [
    ('desktop', desktop),
    ('mobile', mobile),
  ]) {
    testWidgets('right-click opens the menu on $name', (tester) async {
      final h = _Harness(tester);
      await h.mount();
      await h.rightClick('A');

      expect(h.isOpen('A'), isTrue);
    }, variant: variant);

    testWidgets('long-press opens the menu on $name', (tester) async {
      final h = _Harness(tester);
      await h.mount();
      await h.longPress('A');

      expect(h.isOpen('A'), isTrue);
    }, variant: variant);
  }

  testWidgets('opening the menu gives haptic feedback', (tester) async {
    final h = _Harness(tester);
    await h.mount();
    await h.longPress('A');

    expect(h.haptics, isNotEmpty);
  }, variant: mobile);

  testWidgets('choosing an item runs it and closes the menu', (
    tester,
  ) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');
    await tester.tap(find.text('A search'));
    await tester.pumpAndSettle();

    expect(h.selected, ['A search']);
    expect(h.isOpen('A'), isFalse);
  }, variant: desktop);

  testWidgets('tapping outside closes the menu', (tester) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');
    await tester.tapAt(const Offset(380, 380));
    await tester.pumpAndSettle();

    expect(h.isOpen('A'), isFalse);
    expect(h.selected, isEmpty);
  }, variant: desktop);

  testWidgets('dragging outside closes the menu', (tester) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');
    await tester.dragFrom(const Offset(380, 380), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(h.isOpen('A'), isFalse);
  }, variant: desktop);

  testWidgets('right-clicking another target shows only its menu', (
    tester,
  ) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');
    await h.rightClick('B');

    expect(h.isOpen('A'), isFalse);
    expect(h.isOpen('B'), isTrue);
  }, variant: desktop);

  testWidgets('the back button closes the menu and keeps the page', (
    tester,
  ) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(h.isOpen('A'), isFalse);
    expect(find.text('A'), findsOneWidget);
  }, variant: desktop);

  final placements = [
    (name: 'near the bottom-right corner', at: const Offset(300, 340)),
    (name: 'in the middle of a small window', at: const Offset(160, 170)),
  ];
  for (final p in placements) {
    testWidgets('a menu opened ${p.name} stays on screen', (tester) async {
      final h = _Harness(tester);
      await h.mount(targets: {'A': p.at});
      await h.rightClick('A');

      final screen = Offset.zero & _screen;
      for (final rect in h.itemRects('A')) {
        expect(
          screen.intersect(rect),
          rect,
          reason: '$rect is cut off by the screen edge',
        );
      }
    }, variant: desktop);
  }

  testWidgets('a destructive item is shown in the error color', (
    tester,
  ) async {
    final h = _Harness(tester);
    await h.mount();
    await h.rightClick('A');

    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('A delete'),
    );
    final error = Theme.of(
      tester.element(find.text('A')),
    ).colorScheme.error;
    expect(paragraph.text.style?.color, error);
  }, variant: desktop);

  final keys = [
    (name: 'the menu key', keys: [LogicalKeyboardKey.contextMenu]),
    (
      name: 'Shift+F10',
      keys: [LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.f10],
    ),
  ];
  for (final k in keys) {
    testWidgets('${k.name} opens the menu of the focused target', (
      tester,
    ) async {
      final h = _Harness(tester);
      await h.mount();
      await h.focus('A');
      for (final key in k.keys) {
        await tester.sendKeyDownEvent(key);
      }
      for (final key in k.keys.reversed) {
        await tester.sendKeyUpEvent(key);
      }
      await tester.pumpAndSettle();

      expect(h.isOpen('A'), isTrue);
      expect(h.isFocusOn('A copy'), isTrue);
    }, variant: desktop);
  }

  testWidgets('Escape closes a keyboard-opened menu and refocuses its '
      'target', (tester) async {
    final h = _Harness(tester);
    await h.mount();
    await h.focus('A');
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pumpAndSettle();
    expect(h.isOpen('A'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(h.isOpen('A'), isFalse);
    expect(h.isFocusOn('A'), isTrue);
  }, variant: desktop);

  testWidgets('arrows move between menu items', (tester) async {
    final h = _Harness(tester);
    await h.mount();
    await h.focus('A');
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(h.isFocusOn('A search'), isTrue);
  }, variant: desktop);

  testWidgets(
    'with its own triggers off, code still opens the menu and long-press '
    'stays with the target',
    (tester) async {
      final h = _Harness(tester);
      final controller = KurumiContextMenuController();
      var childLongPresses = 0;
      await h.mount(
        controller: controller,
        triggers: false,
        onChildLongPress: () => childLongPresses++,
      );
      await h.longPress('A');

      expect(childLongPresses, 1);
      expect(h.isOpen('A'), isFalse);

      controller.showAt(tester.getCenter(find.text('A')));
      await tester.pumpAndSettle();

      expect(h.isOpen('A'), isTrue);
    },
    variant: mobile,
  );
}
