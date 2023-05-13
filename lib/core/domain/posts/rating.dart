enum Rating {
  sensitive,
  questionable,
  explicit,
  general,
}

Rating mapStringToRating(String str) => switch (str) {
      's' || 'sensitive' => Rating.sensitive,
      'e' || 'explicit' => Rating.explicit,
      'g' || 'general' => Rating.general,
      _ => Rating.questionable,
    };

extension RatingX on Rating {
  bool isNSFW() => this == Rating.explicit || this == Rating.questionable;
  bool isSFW() => !isNSFW();
}
