enum Rating {
  sensitive,
  questionable,
  explicit,
  general,
}

Rating mapStringToRating(String str) {
  switch (str) {
    case 's':
    case 'sensitive':
      return Rating.sensitive;
    case 'e':
    case 'explicit':
      return Rating.explicit;
    case 'g':
    case 'general':
      return Rating.general;
    default:
      return Rating.questionable;
  }
}

extension RatingX on Rating {
  bool isNSFW() => this == Rating.explicit || this == Rating.questionable;
  bool isSFW() => !isNSFW();
}
