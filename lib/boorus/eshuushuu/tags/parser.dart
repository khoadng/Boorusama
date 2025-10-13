// Package imports:
import 'package:booru_clients/eshuushuu.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';

AutocompleteData autocompleteDtoToAutocompleteData(
  AutocompleteDto dto,
  TagType category,
) {
  return AutocompleteData(
    label: dto.value,
    value: _normalizeTagName(dto.value),
    category: parseEshuushuuTagTypeToCategoryName(category),
  );
}

String _normalizeTagName(String name) {
  return name;
}

String parseEshuushuuTagTypeToCategoryName(TagType type) => switch (type) {
  TagType.tag => TagCategory.general().name,
  TagType.artist => TagCategory.artist().name,
  TagType.character => TagCategory.character().name,
  TagType.source => TagCategory.copyright().name,
};

TagType parseTagCategoryToEshuushuuTagType(TagCategory category) =>
    switch (category.name) {
      final name when name == TagCategory.artist().name => TagType.artist,
      final name when name == TagCategory.character().name => TagType.character,
      final name when name == TagCategory.copyright().name => TagType.source,
      final name when name == TagCategory.general().name => TagType.tag,
      _ => TagType.tag,
    };
