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
      return UserLevel.contributor;
    case 37:
      return UserLevel.approver;
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
    case 'contributor':
      return UserLevel.contributor;
    case 'approver':
      return UserLevel.approver;
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

bool isBooruGoldPlusAccount(UserLevel level) {
  switch (level) {
    case UserLevel.restricted:
    case UserLevel.member:
      return false;
    case UserLevel.gold:
    case UserLevel.platinum:
    case UserLevel.builder:
    case UserLevel.contributor:
    case UserLevel.approver:
    case UserLevel.moderator:
    case UserLevel.admin:
    case UserLevel.owner:
      return true;
  }
}

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
