enum SlideshowTransitionType {
  none,
  natural;

  factory SlideshowTransitionType.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'natural' || '1' || 1 => natural,
    _ => defaultValue,
  };

  bool get isSkip => this == none;

  static const SlideshowTransitionType defaultValue = natural;

  dynamic toData() => index;
}
