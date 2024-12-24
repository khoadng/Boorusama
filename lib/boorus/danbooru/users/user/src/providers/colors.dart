// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../../../core/users/user.dart';
import '../types/user.dart';
import '../types/user_level.dart';

int getUserHexOnDarkColor(UserLevel level) => switch (level) {
      UserLevel.member => 0xff009ae7,
      UserLevel.gold => 0xffead084,
      UserLevel.platinum => 0xff808080,
      UserLevel.builder => 0xffc697ff,
      UserLevel.contributor => 0xffc697ff,
      UserLevel.approver => 0xffc697ff,
      UserLevel.moderator => 0xff34c74a,
      UserLevel.admin => 0xffff8b8a,
      UserLevel.owner => 0xffff8b8a,
      UserLevel.restricted => 0xff009ae7
    };

int getUserHexColor(UserLevel level) => switch (level) {
      UserLevel.member => 0xff0073ff,
      UserLevel.gold => 0xffd0ba79,
      UserLevel.platinum => 0xff808080,
      UserLevel.builder => 0xff6633ff,
      UserLevel.contributor => 0xff6633ff,
      UserLevel.approver => 0xffffa500,
      UserLevel.moderator => 0xff33ba48,
      UserLevel.admin => 0xffff0000,
      UserLevel.owner => 0xffff0000,
      UserLevel.restricted => 0xff0073ff
    };

class DanbooruUserColor implements UserColor {
  factory DanbooruUserColor.of(BuildContext context) =>
      DanbooruUserColor._(brightness: Theme.of(context).brightness);
  const DanbooruUserColor._({required this.brightness});

  @override
  final Brightness brightness;

  static Color _color(Brightness brightness, UserLevel? level) {
    final lvl = level ?? UserLevel.member;

    return brightness.isLight
        ? Color(getUserHexColor(lvl))
        : Color(getUserHexOnDarkColor(lvl));
  }

  Color fromLevel(UserLevel? level) => _color(brightness, level);
  Color fromUser(DanbooruUser? user) => _color(brightness, user?.level);
  @override
  Color fromString(String? level) =>
      _color(brightness, stringToUserLevel(level));
  Color fromInt(int? level) => _color(brightness, intToUserLevel(level ?? 0));
}
