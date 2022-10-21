UserLevel intToUserLevel(int value) {
  switch (value) {
    case 10:
      return UserLevel.restricted;
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
    case 60:
      return UserLevel.owner;
    default:
      return UserLevel.member;
  }
}

UserLevel stringToUserLevel(String value) {
  switch (value.toLowerCase()) {
    case 'restricted':
      return UserLevel.restricted;
    case 'member':
      return UserLevel.member;
    case 'gold':
      return UserLevel.gold;
    case 'platinum':
      return UserLevel.platinum;
    case 'builder':
      return UserLevel.builder;
    case 'janitor':
      return UserLevel.janitor;
    case 'moderator':
      return UserLevel.moderator;
    case 'admin':
      return UserLevel.admin;
    case 'owner':
      return UserLevel.owner;
    default:
      return UserLevel.member;
  }
}

enum UserLevel {
  restricted,
  member,
  gold,
  platinum,
  builder,
  janitor,
  moderator,
  admin,
  owner,
}

extension LevelExtension on UserLevel {
  int get hexColor {
    switch (this) {
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
}
