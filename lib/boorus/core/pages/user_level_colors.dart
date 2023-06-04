// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

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

extension UserColor on UserLevel {
  Color toColor() => Color(getUserHexColor(this));
}
