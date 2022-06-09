enum Rating {
  safe,
  questionable,
  explicit,
}

Rating mapStringToRating(String str) {
  switch (str) {
    case 's':
      return Rating.safe;
    case 'e':
      return Rating.explicit;
    default:
      return Rating.questionable;
  }
}
