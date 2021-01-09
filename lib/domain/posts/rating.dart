class Rating {
  final String _rating;

  Rating({
    String rating,
  }) : _rating = rating;

  RatingType get value {
    if (_rating == "s") {
      return RatingType.safe;
    } else if (_rating == "q") {
      return RatingType.questionable;
    } else {
      return RatingType.explicit;
    }
  }
}

enum RatingType {
  safe,
  questionable,
  explicit,
}
