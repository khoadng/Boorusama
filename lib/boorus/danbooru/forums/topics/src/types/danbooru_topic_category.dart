enum DanbooruTopicCategory {
  general,
  tags,
  bugsAndFeatures;

  factory DanbooruTopicCategory.parse(dynamic value) => switch (value) {
    1 => tags,
    2 => bugsAndFeatures,
    _ => general,
  };
}
