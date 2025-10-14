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
  owner;

  factory UserLevel.parse(dynamic value) => switch (value) {
    final int num => switch (num) {
      10 => restricted,
      20 => member,
      30 => gold,
      31 => platinum,
      32 => builder,
      35 => contributor,
      37 => approver,
      40 => moderator,
      50 => admin,
      60 => owner,
      _ => member,
    },
    final String str => switch (str.toLowerCase().trim()) {
      'restricted' => restricted,
      'member' => member,
      'gold' => gold,
      'platinum' => platinum,
      'builder' => builder,
      'contributor' => contributor,
      'approver' => approver,
      'moderator' => moderator,
      'admin' => admin,
      'owner' => owner,
      _ => member,
    },
    _ => member,
  };

  bool get isGoldPlus => switch (this) {
    restricted || member => false,
    _ => true,
  };

  bool get isUnres => switch (this) {
    restricted || member || gold || platinum || builder => false,
    contributor || approver || moderator || admin || owner => true,
  };
}
