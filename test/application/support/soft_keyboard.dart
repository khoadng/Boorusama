import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A phone screen as the app sees it: its logical size, the system areas the
/// hardware reserves, and the height its on-screen keyboard covers.
final class TestPhone {
  const TestPhone({
    required this.name,
    required this.size,
    required this.keyboardHeight,
    this.safeArea = EdgeInsets.zero,
  });

  static const smallPortrait = TestPhone(
    name: 'small portrait phone',
    size: Size(320, 568),
    keyboardHeight: 260,
    safeArea: EdgeInsets.only(top: 20),
  );

  static const portrait = TestPhone(
    name: 'portrait phone',
    size: Size(390, 844),
    keyboardHeight: 300,
    safeArea: EdgeInsets.only(top: 47, bottom: 34),
  );

  static const landscape = TestPhone(
    name: 'landscape phone',
    size: Size(844, 390),
    keyboardHeight: 200,
    safeArea: EdgeInsets.only(left: 47, right: 47, bottom: 21),
  );

  /// Wide enough to cross into the large-screen layout while still being a
  /// phone with an on-screen keyboard.
  static const largeLandscape = TestPhone(
    name: 'large landscape phone',
    size: Size(932, 430),
    keyboardHeight: 200,
    safeArea: EdgeInsets.only(left: 59, right: 59, bottom: 21),
  );

  final String name;
  final Size size;
  final double keyboardHeight;
  final EdgeInsets safeArea;

  @override
  String toString() => name;
}

/// Mirrors the phone's on-screen keyboard: while the app holds the text input
/// open, the bottom [TestPhone.keyboardHeight] of the view is covered.
final class SoftKeyboard {
  SoftKeyboard(this.tester, this.phone);

  final WidgetTester tester;
  TestPhone phone;

  bool get isShown => tester.view.viewInsets.bottom > 0;

  /// Rect of the view that is not covered by system areas or the keyboard.
  Rect get visibleArea {
    final size = phone.size;
    final bottom = isShown ? phone.keyboardHeight : phone.safeArea.bottom;
    return Rect.fromLTRB(
      phone.safeArea.left,
      phone.safeArea.top,
      size.width - phone.safeArea.right,
      size.height - bottom,
    );
  }

  void apply() {
    final ratio = tester.view.devicePixelRatio;
    final padding = _viewPadding(phone.safeArea, ratio);
    tester.view
      ..physicalSize = phone.size * ratio
      ..padding = padding
      ..viewPadding = padding;
    sync(force: true);
  }

  /// Opens or closes the keyboard to match the app's text input, the way the
  /// platform reports it on the next frame.
  void sync({bool force = false}) {
    final shouldShow = tester.testTextInput.isVisible;
    if (!force && shouldShow == isShown) return;

    if (shouldShow) {
      tester.view.viewInsets = FakeViewPadding(
        bottom: phone.keyboardHeight * tester.view.devicePixelRatio,
      );
    } else {
      tester.view.resetViewInsets();
    }
  }

  void reset() {
    tester.view
      ..resetViewInsets()
      ..resetPadding()
      ..resetViewPadding();
  }

  /// Targets a user cannot see or tap because the keyboard, a system area, or
  /// another widget covers them.
  List<String> coveredTargets(Map<String, Finder> targets) => [
    for (final MapEntry(key: name, value: finder) in targets.entries)
      ?_coverage(name, finder),
  ];

  String? _coverage(String name, Finder finder) {
    if (finder.evaluate().isEmpty) return '$name is not on screen';

    final rect = tester.getRect(finder.first);
    final visible = visibleArea;
    final keyboardTop = phone.size.height - phone.keyboardHeight;

    return switch (rect) {
      _ when isShown && rect.bottom > keyboardTop + _tolerance =>
        '$name ends ${(rect.bottom - keyboardTop).round()}px under the '
            'keyboard',
      _ when rect.bottom > visible.bottom + _tolerance =>
        '$name ends ${(rect.bottom - visible.bottom).round()}px under the '
            'bottom safe area',
      _ when rect.top < visible.top - _tolerance =>
        '$name starts ${(visible.top - rect.top).round()}px above the '
            'visible area',
      _ when rect.left < visible.left - _tolerance =>
        '$name starts ${(visible.left - rect.left).round()}px under the left '
            'safe area',
      _ when rect.right > visible.right + _tolerance =>
        '$name ends ${(rect.right - visible.right).round()}px under the right '
            'safe area',
      _ when finder.first.hitTestable().evaluate().isEmpty =>
        '$name is covered by another widget',
      _ => null,
    };
  }

  /// Distance between [finder]'s bottom edge and the top of whatever covers
  /// the bottom of the screen, the keyboard or the bottom safe area.
  double gapAbove(Finder finder) =>
      visibleArea.bottom - tester.getRect(finder.first).bottom;
}

const _tolerance = 0.5;

FakeViewPadding _viewPadding(EdgeInsets insets, double ratio) =>
    FakeViewPadding(
      left: insets.left * ratio,
      top: insets.top * ratio,
      right: insets.right * ratio,
      bottom: insets.bottom * ratio,
    );
