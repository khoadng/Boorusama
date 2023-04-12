enum ImageQuality {
  automatic,
  low,
  high,
  original,
}

enum GridSize {
  small,
  normal,
  large,
}

enum ImageListType {
  standard,
  masonry,
}

enum DohOptions {
  none,
  cloudflare,
  google,
}

List<int> getPostsPerPagePossibleValue() =>
    [20, 40, 50, 60, 80, 100, 120, 150, 200];
