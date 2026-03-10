enum ItemOverflowMode {
  none,
  clamp;

  factory ItemOverflowMode.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'clamp' || '1' || 1 => clamp,
    _ => defaultValue,
  };

  static const ItemOverflowMode defaultValue = none;

  bool get isActive => this != none;

  dynamic toData() => index;
}
