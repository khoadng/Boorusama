// Dart imports:
import 'dart:async';

// Project imports:
import '../../../../../core/tags/categories/tag_category.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../posts/post/post.dart';

class DanbooruTagExtractor implements TagExtractor<DanbooruPost> {
  const DanbooruTagExtractor();

  @override
  FutureOr<List<Tag>> extractTags(DanbooruPost post) {
    final tags = <Tag>[];

    for (final t in post.artistTags) {
      tags.add(
        Tag.noCount(
          name: t,
          category: TagCategory.artist(),
        ),
      );
    }

    for (final t in post.copyrightTags) {
      tags.add(
        Tag.noCount(
          name: t,
          category: TagCategory.copyright(),
        ),
      );
    }

    for (final t in post.characterTags) {
      tags.add(
        Tag.noCount(
          name: t,
          category: TagCategory.character(),
        ),
      );
    }

    for (final t in post.metaTags) {
      tags.add(
        Tag.noCount(
          name: t,
          category: TagCategory.meta(),
        ),
      );
    }

    for (final t in post.generalTags) {
      tags.add(
        Tag.noCount(
          name: t,
          category: TagCategory.general(),
        ),
      );
    }

    return tags;
  }
}
