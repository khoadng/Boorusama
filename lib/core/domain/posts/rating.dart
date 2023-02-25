enum Rating {
  sensitive,
  questionable,
  explicit,
  general,
}

Rating mapStringToRating(String str) {
  switch (str) {
    case 's':
      return Rating.sensitive;
    case 'e':
      return Rating.explicit;
    case 'g':
      return Rating.general;
    default:
      return Rating.questionable;
  }
}

extension RatingX on Rating {
  bool isNSFW() => this == Rating.explicit || this == Rating.questionable;
  bool isSFW() => !isNSFW();
}
