// Package imports:
import 'package:booru_clients/hybooru.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';

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
