UserLevel intToUserLevel(int value) {
  switch (value) {
    case 20:
      return UserLevel.member;
    case 30:
      return UserLevel.gold;
    case 31:
      return UserLevel.platinum;
    case 32:
      return UserLevel.builder;
    case 35:
      return UserLevel.janitor;
    case 40:
      return UserLevel.moderator;
    case 50:
      return UserLevel.admin;
    default:
      return UserLevel.member;
  }
}

enum UserLevel {
  member,
  gold,
  platinum,
  builder,
  janitor,
  moderator,
  admin,
}

extension LevelExtension on UserLevel {
  int get hexColor {
    switch (this) {
      case UserLevel.member:
        return 0xff0073ff;
      case UserLevel.gold:
        return 0xff0000ff;
      case UserLevel.platinum:
        return 0xff808080;
      case UserLevel.builder:
        return 0xff6633ff;
      case UserLevel.janitor:
        return 0xffffa500;
      case UserLevel.moderator:
        return 0xffffa500;
      case UserLevel.admin:
        return 0xffff0000;
      default:
        return 0xff0073ff;
    }
  }
}
