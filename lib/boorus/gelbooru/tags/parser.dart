// Package imports:
import 'package:booru_clients/gelbooru.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../common/parser.dart';
import 'utils.dart';

Tag gelbooruTagDtoToTag(TagDto e) {
  return Tag(
    name: e.name != null ? decodeHtmlEntities(e.name!) : '',
    category: stringToGelbooruTagCategory(e.type?.toString()),
    postCount: e.count ?? 0,
  );
}

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) {
  try {
    return AutocompleteData(
      type: e.type,
      label: e.label?.replaceAll('_', ' ') ?? '<empty>',
      value: _extractAutocompleteTag(e),
      category: e.category?.toString(),
      postCount: e.postCount,
    );
  } catch (err) {
    return AutocompleteData.empty;
  }
}

String _extractAutocompleteTag(AutocompleteDto dto) {
  final label = dto.label;
  final value = dto.value;

  // if label start with '{' use it as value, this is used for OR tags
  if (label != null && label.startsWith('{')) {
    return label.replaceAll(' ', '_');
  }

  return value ?? label ?? '';
}
