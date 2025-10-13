enum MediaBlurCondition {
  none,
  explicitOnly;

  factory MediaBlurCondition.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'explicitOnly' || '1' || 1 => explicitOnly,
    _ => defaultValue,
  };

  static const MediaBlurCondition defaultValue = none;

  bool get blurExplicitMedia => this == explicitOnly;

  dynamic toData() => index;
}
