// Package imports:
import 'package:booru_clients/zerochan.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';

Tag? tagDtoToTag(TagDto e) => switch (e) {
  TagDto(:final value?, :final type) => Tag.noCount(
    name: normalizeZerochanTag(value),
    category: zerochanStringToTagCategory(type),
  ),
  _ => null,
};

Tag? autocompleteDataToTag(AutocompleteData e) => switch (e) {
  AutocompleteData(:final value, :final category) when value.isNotEmpty => Tag(
    name: normalizeZerochanTag(value),
    category: zerochanStringToTagCategory(category),
    postCount: e.postCount ?? 0,
  ),
  _ => null,
};

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) =>
    AutocompleteData(
      label: e.value?.toLowerCase() ?? '',
      value: e.value?.toLowerCase() ?? '',
      postCount: e.total,
      antecedent: switch (e.alias) {
        null || '' => null,
        final alias => normalizeZerochanTag(alias),
      },
      category: switch (e.type) {
        null || '' => null,
        final type => normalizeZerochanTag(type),
      },
    );

TagCategory zerochanStringToTagCategory(String? value) {
  // remove ' fav' and ' primary' from the end of the string
  final type = value?.toLowerCase().replaceAll(RegExp(r' fav$| primary$'), '');

  return switch (type) {
    'mangaka' || 'artist' || 'studio' => TagCategory.artist(),
    'series' ||
    'copyright' ||
    'game' ||
    'visual novel' => TagCategory.copyright(),
    'character' => TagCategory.character(),
    'meta' || 'source' => TagCategory.meta(),
    _ => TagCategory.general(),
  };
}

String normalizeZerochanTag(String tag) {
  return tag.toLowerCase().replaceAll(' ', '_');
}
