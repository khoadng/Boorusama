// Package imports:
import 'package:booru_clients/hybooru.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) {
  final tagName = e.name ?? '';
  final parts = tagName.split(':');
  final category = parts.length > 1 ? parts[0] : 'general';
  final displayName = parts.length > 1 ? parts[1] : tagName;

  return AutocompleteData(
    label: displayName.toLowerCase().replaceAll('_', ' '),
    value: tagName.toLowerCase(),
    postCount: e.posts,
    category: category,
  );
}

Tag tagDtoToTag(TagDto dto) {
  return Tag(
    name: dto.name ?? '',
    category: _mapTagTypeToTagCategory(dto.type),
    postCount: dto.count,
  );
}

TagCategory _mapTagTypeToTagCategory(TagType type) {
  return switch (type) {
    TagType.artist || TagType.creator => TagCategory.artist(),
    TagType.character || TagType.person => TagCategory.character(),
    TagType.copyright ||
    TagType.series ||
    TagType.studio => TagCategory.copyright(),
    TagType.meta || TagType.system || TagType.rating => TagCategory.meta(),
    TagType.medium || TagType.fm || TagType.general => TagCategory.general(),
  };
}
