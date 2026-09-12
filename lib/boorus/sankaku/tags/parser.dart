// Package imports:
import 'package:booru_clients/sankaku.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import 'metatags.dart';

AutocompleteData tagDtoToAutocompleteData(TagDto e) {
  if (e case TagDto(type: 9, name: final name?)) {
    final separator = name.indexOf(':');
    final prefix = separator > 0 ? name.substring(0, separator) : null;
    final recognized = kSankakuMetatags.any((tag) => tag.name == prefix);
    return AutocompleteData(
      type: switch (prefix) {
        'fav' || 'user' => AutocompleteData.user,
        'pool' => AutocompleteData.pool,
        _ => null,
      },
      label: recognized && separator < name.length - 1
          ? name.substring(separator + 1)
          : name,
      value: name,
      postCount: e.count,
    );
  }

  final alias = e.aliasOf;
  // if alias is available, we use the alias name instead and point to the original tag
  return alias != null
      ? AutocompleteData(
          label: alias.tagName?.toLowerCase().replaceAll('_', ' ') ?? '???',
          value: alias.tagName ?? '???',
          postCount: alias.postCount,
          category: alias.type?.toString(),
          antecedent: e.tagName,
        )
      : AutocompleteData(
          label: e.name?.toLowerCase().replaceAll('_', ' ') ?? '???',
          value: e.tagName ?? '???',
          postCount: e.count,
          category: e.type?.toString(),
        );
}
