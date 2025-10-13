enum BooruConfigScrollDirection {
  normal,
  reversed;

  factory BooruConfigScrollDirection.parse(dynamic value) => switch (value) {
    'normal' || '0' || 0 => normal,
    'reversed' || '1' || 1 => reversed,
    _ => defaultValue,
  };

  bool get isReversed => this == reversed;

  static const BooruConfigScrollDirection defaultValue = normal;

  dynamic toData() => index;
}
