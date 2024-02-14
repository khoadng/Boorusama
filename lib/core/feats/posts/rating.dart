enum Rating {
  unknown,
  explicit,
  questionable,
  sensitive,
  general,
}

Rating mapStringToRating(String? str) => switch (str?.toLowerCase()) {
      's' || 'sensitive' => Rating.sensitive,
      'e' || 'explicit' => Rating.explicit,
      'g' || 'general' => Rating.general,
      'q' || 'questionable' => Rating.questionable,
      _ => Rating.unknown,
    };

extension RatingX on Rating {
  bool isNSFW() => this == Rating.explicit || this == Rating.questionable;
  bool isSFW() => !isNSFW();

  String toFullString({
    bool legacy = false,
  }) =>
      switch (this) {
        Rating.sensitive => legacy ? 'safe' : 'sensitive',
        Rating.explicit => 'explicit',
        Rating.general => 'general',
        Rating.questionable => 'questionable',
        Rating.unknown => '',
      };

  String toShortString() => switch (this) {
        Rating.sensitive => 's',
        Rating.explicit => 'e',
        Rating.general => 'g',
        Rating.questionable => 'q',
        Rating.unknown => '',
      };
}
