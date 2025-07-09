UserLevel intToUserLevel(int value) => switch (value) {
  10 => UserLevel.restricted,
  20 => UserLevel.member,
  30 => UserLevel.gold,
  31 => UserLevel.platinum,
  32 => UserLevel.builder,
  35 => UserLevel.contributor,
  37 => UserLevel.approver,
  40 => UserLevel.moderator,
  50 => UserLevel.admin,
  60 => UserLevel.owner,
  _ => UserLevel.member,
};

UserLevel stringToUserLevel(String? value) => switch (value?.toLowerCase()) {
  'restricted' => UserLevel.restricted,
  'member' => UserLevel.member,
  'gold' => UserLevel.gold,
  'platinum' => UserLevel.platinum,
  'builder' => UserLevel.builder,
  'contributor' => UserLevel.contributor,
  'approver' => UserLevel.approver,
  'moderator' => UserLevel.moderator,
  'admin' => UserLevel.admin,
  'owner' => UserLevel.owner,
  _ => UserLevel.member,
};

bool isBooruGoldPlusAccount(UserLevel level) => switch (level) {
  UserLevel.restricted || UserLevel.member => false,
  _ => true,
};

bool isBooruGoldPlusAccountInt(int level) =>
    isBooruGoldPlusAccount(intToUserLevel(level));

enum UserLevel {
  restricted,
  member,
  gold,
  platinum,
  builder,
  contributor,
  approver,
  moderator,
  admin,
  owner,
}

class DanbooruUserLevel {
  const DanbooruUserLevel._(this.level);

  factory DanbooruUserLevel.of(UserLevel? level) => DanbooruUserLevel._(level);

  final UserLevel? level;

  bool get isUnres => switch (level) {
    null => false,
    UserLevel.restricted ||
    UserLevel.member ||
    UserLevel.gold ||
    UserLevel.platinum ||
    UserLevel.builder => false,
    UserLevel.contributor ||
    UserLevel.approver ||
    UserLevel.moderator ||
    UserLevel.admin ||
    UserLevel.owner => true,
  };
}
