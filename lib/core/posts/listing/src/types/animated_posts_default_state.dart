enum AnimatedPostsDefaultState {
  autoplay,
  static;

  factory AnimatedPostsDefaultState.parse(dynamic value) => switch (value) {
    'autoplay' || '0' || 0 => autoplay,
    'static' || '1' || 1 => static,
    _ => defaultValue,
  };

  static const AnimatedPostsDefaultState defaultValue = autoplay;

  dynamic toData() => index;
}
