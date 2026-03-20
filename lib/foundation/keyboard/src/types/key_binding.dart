// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../platform.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class KeyBinding extends Equatable {
  const KeyBinding({
    required this.key,
    this.primaryModifier = false,
    this.secondaryModifier = false,
    this.shift = false,
    this.alt = false,
  });

  factory KeyBinding.fromJson(Map<String, dynamic> json) {
    return KeyBinding(
      key: json['key'] as int? ?? 0,
      primaryModifier: json['primaryModifier'] as bool? ?? false,
      secondaryModifier: json['secondaryModifier'] as bool? ?? false,
      shift: json['shift'] as bool? ?? false,
      alt: json['alt'] as bool? ?? false,
    );
  }

  /// Creates a [KeyBinding] from a raw key event captured on the current
  /// platform. Translates platform-specific ctrl/meta into abstract modifiers.
  factory KeyBinding.fromKeyEvent(KeyEvent event, HardwareKeyboard keyboard) {
    final isMac = hasMacKeyboard();

    return KeyBinding(
      key: event.logicalKey.keyId,
      primaryModifier: isMac
          ? keyboard.isMetaPressed
          : keyboard.isControlPressed,
      secondaryModifier: isMac
          ? keyboard.isControlPressed
          : keyboard.isMetaPressed,
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
    );
  }

  final int key;

  /// The primary action modifier: Ctrl on Windows/Linux, Cmd on macOS.
  final bool primaryModifier;

  /// The secondary modifier: Meta/Super on Windows/Linux, Ctrl on macOS.
  /// Rarely used — most shortcuts only need [primaryModifier].
  final bool secondaryModifier;

  final bool shift;
  final bool alt;

  SingleActivator toSingleActivator() {
    final logicalKey = LogicalKeyboardKey.findKeyByKeyId(key);
    if (logicalKey == null) {
      return const SingleActivator(LogicalKeyboardKey.abort);
    }

    final isMac = hasMacKeyboard();

    return SingleActivator(
      logicalKey,
      control: isMac ? secondaryModifier : primaryModifier,
      meta: isMac ? primaryModifier : secondaryModifier,
      shift: shift,
      alt: alt,
    );
  }

  bool matchesEvent(KeyEvent event, HardwareKeyboard keyboard) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey.keyId != key) return false;

    final isMac = hasMacKeyboard();
    final expectCtrl = isMac ? secondaryModifier : primaryModifier;
    final expectMeta = isMac ? primaryModifier : secondaryModifier;

    if (expectCtrl != keyboard.isControlPressed) return false;
    if (expectMeta != keyboard.isMetaPressed) return false;
    if (shift != keyboard.isShiftPressed) return false;
    if (alt != keyboard.isAltPressed) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      if (primaryModifier) 'primaryModifier': primaryModifier,
      if (secondaryModifier) 'secondaryModifier': secondaryModifier,
      if (shift) 'shift': shift,
      if (alt) 'alt': alt,
    };
  }

  /// Returns each key as a separate string, suitable for rendering
  /// individual keycap chips.
  List<String> displayParts() {
    final parts = <String>[];
    final isMac = hasMacKeyboard();

    if (primaryModifier) parts.add(isMac ? '\u2318' : 'Ctrl');
    if (secondaryModifier) parts.add(isMac ? '\u2303' : 'Super');
    if (alt) parts.add(isMac ? '\u2325' : 'Alt');
    if (shift) parts.add(isMac ? '\u21E7' : 'Shift');

    final logicalKey = LogicalKeyboardKey.findKeyByKeyId(key);
    if (logicalKey != null) {
      parts.add(_keyLabel(logicalKey));
    }

    return parts;
  }

  String displayLabel() {
    final parts = displayParts();
    return hasMacKeyboard() ? parts.join() : parts.join('+');
  }

  static String _keyLabel(LogicalKeyboardKey key) {
    return switch (key) {
      LogicalKeyboardKey.arrowUp => '\u2191',
      LogicalKeyboardKey.arrowDown => '\u2193',
      LogicalKeyboardKey.arrowLeft => '\u2190',
      LogicalKeyboardKey.arrowRight => '\u2192',
      LogicalKeyboardKey.escape => 'Esc',
      LogicalKeyboardKey.enter => '\u23CE',
      LogicalKeyboardKey.backspace => '\u232B',
      LogicalKeyboardKey.delete => 'Del',
      LogicalKeyboardKey.tab => 'Tab',
      LogicalKeyboardKey.space => 'Space',
      _ => key.keyLabel,
    };
  }

  @override
  List<Object?> get props => [
    key,
    primaryModifier,
    secondaryModifier,
    shift,
    alt,
  ];
}
