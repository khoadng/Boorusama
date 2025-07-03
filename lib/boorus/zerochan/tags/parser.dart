// Package imports:
import 'package:booru_clients/zerochan.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';

Tag tagDtoToTag(TagDto e) => Tag.noCount(
      name: normalizeZerochanTag(e.value)!,
      category: zerochanStringToTagCategory(e.type),
    );

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) =>
    AutocompleteData(
      label: e.value?.toLowerCase() ?? '',
      value: e.value?.toLowerCase() ?? '',
      postCount: e.total,
      antecedent: normalizeZerochanTag(e.alias),
      category: normalizeZerochanTag(e.type) ?? '',
    );

TagCategory zerochanStringToTagCategory(String? value) {
  // remove ' fav' and ' primary' from the end of the string
  final type = value?.toLowerCase().replaceAll(RegExp(r' fav$| primary$'), '');

  return switch (type) {
    'mangaka' || 'artist' || 'studio' => TagCategory.artist(),
    'series' ||
    'copyright' ||
    'game' ||
    'visual novel' =>
      TagCategory.copyright(),
    'character' => TagCategory.character(),
    'meta' || 'source' => TagCategory.meta(),
    _ => TagCategory.general(),
  };
}

String? normalizeZerochanTag(String? tag) {
  return tag?.toLowerCase().replaceAll(' ', '_');
}
