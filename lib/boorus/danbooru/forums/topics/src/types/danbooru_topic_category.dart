enum DanbooruTopicCategory {
  general,
  tags,
  bugsAndFeatures,
}

DanbooruTopicCategory intToDanbooruTopicCategory(int value) => switch (value) {
  1 => DanbooruTopicCategory.tags,
  2 => DanbooruTopicCategory.bugsAndFeatures,
  _ => DanbooruTopicCategory.general,
};

int danbooruTopicCategoryToInt(DanbooruTopicCategory value) => switch (value) {
  DanbooruTopicCategory.general => 0,
  DanbooruTopicCategory.tags => 1,
  DanbooruTopicCategory.bugsAndFeatures => 2,
};
