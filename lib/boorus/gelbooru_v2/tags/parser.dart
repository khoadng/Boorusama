// Package imports:
import 'package:booru_clients/gelbooru.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';

Tag mapGelbooruV2TagDtoToTag(TagDto e) {
  return Tag(
    name: e.name ?? '',
    category: TagCategory.fromLegacyId(e.type),
    postCount: e.count ?? 0,
  );
}

AutocompleteData mapGelbooruV2AutocompleteDtoToData(AutocompleteDto e) {
  try {
    return AutocompleteData(
      type: e.type,
      label: e.label?.replaceAll('_', ' ') ?? '<empty>',
      value: e.value!,
      category: e.category?.toString(),
      postCount: e.postCount,
    );
  } catch (err) {
    return AutocompleteData.empty;
  }
}
