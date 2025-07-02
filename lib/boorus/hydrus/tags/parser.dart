// Package imports:
import 'package:booru_clients/hydrus.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';

AutocompleteData parseHydrusAutocompleteData(AutocompleteDto dto) {
  final category = parseHydrusCategory(dto.value);

  return AutocompleteData(
    label: dto.value,
    value: dto.value,
    category: category,
    postCount: dto.count,
  );
}

// Parses the category from a tag string (e.g., "artist:name" -> "artist")
String? parseHydrusCategory(String value) {
  return RegExp(r'(\w+):').firstMatch(value)?.group(1);
}
