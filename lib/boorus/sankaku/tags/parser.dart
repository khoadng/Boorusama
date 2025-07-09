// Package imports:
import 'package:booru_clients/sankaku.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';

AutocompleteData tagDtoToAutocompleteData(TagDto e) {
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
