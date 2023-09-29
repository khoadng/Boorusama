enum Rating {
  sensitive,
  questionable,
  explicit,
  general,
}

Rating mapStringToRating(String? str) => switch (str?.toLowerCase()) {
      's' || 'sensitive' => Rating.sensitive,
      'e' || 'explicit' => Rating.explicit,
      'g' || 'general' => Rating.general,
      'q' || 'questionable' => Rating.questionable,
      _ => Rating.sensitive,
    };

extension RatingX on Rating {
  bool isNSFW() => this == Rating.explicit || this == Rating.questionable;
  bool isSFW() => !isNSFW();
}
