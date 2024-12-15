// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/tags/categories/tag_category.dart';
import 'danbooru_related_tag.dart';

List<DanbooruRelatedTagItem> generateDummyTags(int count) => [
      for (var i = 0; i < count; i++)
        DanbooruRelatedTagItem(
          tag: generateRandomWord(3, 12),
          cosineSimilarity: 1,
          jaccardSimilarity: 1,
          overlapCoefficient: 1,
          frequency: 1,
          postCount: 1,
          category: switch (i % 10) {
            0 => TagCategory.artist(),
            1 => TagCategory.character(),
            2 => TagCategory.copyright(),
            3 => TagCategory.meta(),
            _ => TagCategory.general(),
          },
        ),
    ];
