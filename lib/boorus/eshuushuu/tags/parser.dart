// Package imports:
import 'package:booru_clients/eshuushuu.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';

AutocompleteData autocompleteDtoToAutocompleteData(
  AutocompleteDto dto,
) {
  final tagType = TagType.tryParse(dto.type) ?? TagType.tag;
  final title = dto.title ?? '';

  return AutocompleteData(
    label: title,
    value: title,
    category: parseEshuushuuTagTypeToCategoryName(tagType),
    postCount: dto.usageCount,
    antecedent: dto.aliasOfName,
    type: (dto.isAlias ?? false)
        ? AutocompleteData.alias
        : AutocompleteData.tag,
  );
}

String parseEshuushuuTagTypeToCategoryName(TagType type) => switch (type) {
  TagType.tag => TagCategory.general().name,
  TagType.artist => TagCategory.artist().name,
  TagType.character => TagCategory.character().name,
  TagType.source => TagCategory.copyright().name,
};
