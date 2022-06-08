class UserLevel {
  final int _level;

  UserLevel(this._level);

  Level get level {
    switch (_level) {
      case 20:
        return Level.member;
      case 30:
        return Level.gold;
      case 31:
        return Level.platinum;
      case 32:
        return Level.builder;
      case 35:
        return Level.janitor;
      case 40:
        return Level.moderator;
      case 50:
        return Level.admin;
      default:
        return Level.member;
    }
  }
}

enum Level {
  member,
  gold,
  platinum,
  builder,
  janitor,
  moderator,
  admin,
}

extension LevelExtension on Level {
  int get hexColor {
    switch (this) {
      case Level.member:
        return 0xff0073ff;
      case Level.gold:
        return 0xff0000ff;
      case Level.platinum:
        return 0xff808080;
      case Level.builder:
        return 0xff6633ff;
      case Level.janitor:
        return 0xffffa500;
      case Level.moderator:
        return 0xffffa500;
      case Level.admin:
        return 0xffff0000;
      default:
        return 0xff0073ff;
    }
  }
}
