// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

int getUserHexColor(UserLevel level) {
  switch (level) {
    case UserLevel.member:
      return 0xff0073ff;
    case UserLevel.gold:
      return 0xffd0ba79;
    case UserLevel.platinum:
      return 0xff808080;
    case UserLevel.builder:
      return 0xff6633ff;
    case UserLevel.janitor:
      return 0xffffa500;
    case UserLevel.moderator:
      return 0xff33ba48;
    case UserLevel.admin:
      return 0xffff0000;
    case UserLevel.owner:
      return 0xffff0000;
    case UserLevel.restricted:
      return 0xff0073ff;
  }
}
