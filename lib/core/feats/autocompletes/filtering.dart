// Project imports:
import 'package:boorusama/functional.dart';
import 'autocomplete.dart';

bool isSfwTag({
  required String value,
  String? antecedent,
  required Set<String> nsfwTags,
}) {
  for (final tag in nsfwTags) {
    if (value.contains(tag)) {
      return false;
    }

    if (antecedent?.contains(tag) ?? false) {
      return false;
    }
  }

  final words = value.split('_');
  final aliasWords = antecedent?.split('_') ?? [];

  for (final tag in nsfwTags) {
    for (final word in words) {
      if (word.contains(tag)) {
        return false;
      }
    }

    for (final word in aliasWords) {
      if (word.contains(tag)) {
        return false;
      }
    }
  }

  return true;
}

List<String> filterNsfwRawTagString(
  String tag,
  Set<String> nsfwTags, {
  bool shouldFilter = true,
}) {
  final tags = tag.split(' ').toList();

  return shouldFilter
      ? tags
          .where((e) => isSfwTag(
                value: e,
                nsfwTags: nsfwTags,
              ))
          .toList()
      : tags;
}

IList<AutocompleteData> filterNsfw(
  List<AutocompleteData> data,
  Set<String> nsfwTags, {
  bool shouldFilter = true,
}) {
  return shouldFilter
      ? data
          .where((e) => isSfwTag(
                value: e.value,
                antecedent: e.antecedent,
                nsfwTags: nsfwTags,
              ))
          .toList()
          .lock
      : data.lock;
}
