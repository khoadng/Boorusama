enum BooruConfigRatingFilter {
  none,
  hideExplicit,
  hideNSFW,
  custom;

  factory BooruConfigRatingFilter.parse(dynamic value) => switch (value) {
    0 || '0' || 'none' => none,
    1 || '1' || 'hideExplicit' => hideExplicit,
    2 || '2' || 'hideNSFW' => hideNSFW,
    3 || '3' || 'custom' => custom,
    _ => defaultValue,
  };

  static const BooruConfigRatingFilter defaultValue = hideNSFW;
}
