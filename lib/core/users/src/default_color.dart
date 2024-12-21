// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'user_color.dart';

class DefaultUserColor implements UserColor {
  DefaultUserColor._(this.brightness);

  factory DefaultUserColor.of(BuildContext context) =>
      DefaultUserColor._(Theme.of(context).brightness);

  @override
  final Brightness brightness;

  @override
  Color fromString(String color) {
    return brightness != Brightness.light
        ? Color(getUserHexColor(color))
        : Color(getUserHexOnDarkColor(color));
  }
}

int getUserHexOnDarkColor(String level) => switch (level.toLowerCase()) {
      'member' => 0xff009ae7,
      'gold' => 0xffead084,
      'platinum' => 0xff808080,
      'builder' => 0xffc697ff,
      'contributor' => 0xffc697ff,
      'approver' => 0xffc697ff,
      'moderator' => 0xff34c74a,
      'admin' => 0xffff8b8a,
      'owner' => 0xffff8b8a,
      'restricted' => 0xff009ae7,
      _ => 0xff009ae7,
    };

int getUserHexColor(String level) => switch (level.toLowerCase()) {
      'member' => 0xff0073ff,
      'gold' => 0xffd0ba79,
      'platinum' => 0xff808080,
      'builder' => 0xff6633ff,
      'contributor' => 0xff6633ff,
      'approver' => 0xffffa500,
      'moderator' => 0xff33ba48,
      'admin' => 0xffff0000,
      'owner' => 0xffff0000,
      'restricted' => 0xff0073ff,
      _ => 0xff0073ff,
    };
