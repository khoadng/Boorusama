// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';

class TagGroupItem extends Equatable {
  const TagGroupItem({
    required this.category,
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final int category;
  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;

  @override
  List<Object?> get props => [category, groupName, tags, order];
}

extension TagGroupItemX on TagGroupItem {
  List<String> extractRawTag(TagCategory category) =>
      tags.where((e) => category == e.category).map((e) => e.rawName).toList();

  List<String> extractArtistTags() => extractRawTag(TagCategory.artist);
  List<String> extractCharacterTags() => extractRawTag(TagCategory.charater);
  List<String> extractGeneralTags() => extractRawTag(TagCategory.general);
  List<String> extractMetaTags() => extractRawTag(TagCategory.meta);
  List<String> extractCopyRightTags() => extractRawTag(TagCategory.copyright);
}
