// Flutter imports:
import 'package:flutter/material.dart';

extension FlutterX on BuildContext {
  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

  double get screenHeight => MediaQuery.sizeOf(this).height;

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenAspectRatio =>
      screenWidth != 0 ? screenHeight / screenWidth : 0;

  NavigatorState get navigator => Navigator.of(this);
  NavigatorState? get maybeNavigator => Navigator.maybeOf(this);

  FocusScopeNode get focusScope => FocusScope.of(this);

  ScaffoldState get scaffold => Scaffold.of(this);

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
}

extension MaterialStateHelpers on Iterable<WidgetState> {
  bool get isHovered => contains(WidgetState.hovered);
  bool get isFocused => contains(WidgetState.focused);
  bool get isPressed => contains(WidgetState.pressed);
  bool get isDragged => contains(WidgetState.dragged);
  bool get isSelected => contains(WidgetState.selected);
  bool get isScrolledUnder => contains(WidgetState.scrolledUnder);
  bool get isDisabled => contains(WidgetState.disabled);
  bool get isError => contains(WidgetState.error);
}

class ShrinkVisualDensity extends VisualDensity {
  const ShrinkVisualDensity() : super(horizontal: -4, vertical: -4);
}

extension TextEditingControllerX on TextEditingController {
  void setTextAndCollapseSelection(String text) {
    this
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }
}
