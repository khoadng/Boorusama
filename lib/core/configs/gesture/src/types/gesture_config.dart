// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

enum GestureType {
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  doubleTap,
  longPress,
  tap,
}

class GestureConfig extends Equatable {
  const GestureConfig({
    required this.swipeUp,
    required this.swipeDown,
    required this.swipeLeft,
    required this.swipeRight,
    required this.doubleTap,
    required this.longPress,
    required this.tap,
  });

  const GestureConfig.undefined()
      : swipeUp = null,
        swipeDown = null,
        swipeLeft = null,
        swipeRight = null,
        doubleTap = null,
        longPress = null,
        tap = null;

  factory GestureConfig.fromJson(Map<String, dynamic> json) {
    return GestureConfig(
      swipeUp: json['swipeUp'] as String?,
      swipeDown: json['swipeDown'] as String?,
      swipeLeft: json['swipeLeft'] as String?,
      swipeRight: json['swipeRight'] as String?,
      doubleTap: json['doubleTap'] as String?,
      longPress: json['longPress'] as String?,
      tap: json['tap'] as String?,
    );
  }
  final String? swipeUp;
  final String? swipeDown;
  final String? swipeLeft;
  final String? swipeRight;
  final String? doubleTap;
  final String? longPress;
  final String? tap;

  GestureConfig copyWith({
    String? Function()? swipeUp,
    String? Function()? swipeDown,
    String? Function()? swipeLeft,
    String? Function()? swipeRight,
    String? Function()? doubleTap,
    String? Function()? longPress,
    String? Function()? tap,
  }) {
    return GestureConfig(
      swipeUp: swipeUp != null ? swipeUp() : this.swipeUp,
      swipeDown: swipeDown != null ? swipeDown() : this.swipeDown,
      swipeLeft: swipeLeft != null ? swipeLeft() : this.swipeLeft,
      swipeRight: swipeRight != null ? swipeRight() : this.swipeRight,
      doubleTap: doubleTap != null ? doubleTap() : this.doubleTap,
      longPress: longPress != null ? longPress() : this.longPress,
      tap: tap != null ? tap() : this.tap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (swipeUp != null) 'swipeUp': swipeUp,
      if (swipeDown != null) 'swipeDown': swipeDown,
      if (swipeLeft != null) 'swipeLeft': swipeLeft,
      if (swipeRight != null) 'swipeRight': swipeRight,
      if (doubleTap != null) 'doubleTap': doubleTap,
      if (longPress != null) 'longPress': longPress,
      if (tap != null) 'tap': tap,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [
        swipeUp,
        swipeDown,
        swipeLeft,
        swipeRight,
        doubleTap,
        longPress,
        tap,
      ];
}

extension BooruBuilderGestures on GestureConfig? {
  bool canHandleGesture(GestureType gesture) {
    final gestures = this;
    if (gestures == null) return false;

    return switch (gesture) {
      GestureType.swipeDown => gestures.swipeDown != null,
      GestureType.swipeUp => gestures.swipeUp != null,
      GestureType.swipeLeft => gestures.swipeLeft != null,
      GestureType.swipeRight => gestures.swipeRight != null,
      GestureType.doubleTap => gestures.doubleTap != null,
      GestureType.longPress => gestures.longPress != null,
      GestureType.tap => gestures.tap != null,
    };
  }

  bool get canLongPress => canHandleGesture(GestureType.longPress);
  bool get canDoubleTap => canHandleGesture(GestureType.doubleTap);
  bool get canTap => canHandleGesture(GestureType.tap);
  bool get canSwipeDown => canHandleGesture(GestureType.swipeDown);
  bool get canSwipeUp => canHandleGesture(GestureType.swipeUp);
  bool get canSwipeLeft => canHandleGesture(GestureType.swipeLeft);
  bool get canSwipeRight => canHandleGesture(GestureType.swipeRight);
}
