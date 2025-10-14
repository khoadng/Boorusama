enum Rating {
  unknown,
  explicit,
  questionable,
  sensitive,
  general;

  factory Rating.parse(dynamic value) => switch (value) {
    final String str => switch (str.toLowerCase()) {
      's' || 'sensitive' => sensitive,
      'e' || 'explicit' => explicit,
      'g' || 'general' => general,
      'q' || 'questionable' => questionable,
      _ => unknown,
    },
    _ => unknown,
  };

  bool isNSFW() => this == explicit || this == questionable;
  bool isSFW() => !isNSFW();

  String toFullString({
    bool legacy = false,
  }) => switch (this) {
    sensitive => legacy ? 'safe' : 'sensitive',
    explicit => 'explicit',
    general => 'general',
    questionable => 'questionable',
    unknown => '',
  };

  String toShortString() => switch (this) {
    sensitive => 's',
    explicit => 'e',
    general => 'g',
    questionable => 'q',
    unknown => '',
  };

  bool get isExplicit => this == explicit;
}
