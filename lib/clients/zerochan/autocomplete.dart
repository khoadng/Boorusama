import 'dart:convert';

import 'package:boorusama/clients/zerochan/types/types.dart';

List<AutocompleteDto> parseAutocomplete(dynamic data) {
  final z1 = _parseZerochanAutocomplete(data);

  if (z1 != null) return z1;

  final z2 = _parseZerochanAltAutocomplete(data);

  if (z2 != null) return z2;

  throw Exception('Failed to parse autocomplete, unknown format');
}

List<AutocompleteDto>? _parseZerochanAutocomplete(dynamic data) {
  try {
    final json = jsonDecode(data);
    final rawData = json['suggestions'];

    if (rawData == null) return null;

    return (rawData as List).map((e) => AutocompleteDto.fromJson(e)).toList();
  } catch (e) {
    return null;
  }
}

List<AutocompleteDto>? _parseZerochanAltAutocomplete(dynamic data) {
  final input = data is String ? data : null;

  if (input == null) return null;

  final rows = input.split('\n');

  try {
    return rows.map((e) {
      final parts = e.split('|');

      return AutocompleteDto(
        value: parts.isNotEmpty ? parts[0] : null,
        type: parts.length > 1 ? parts[1] : null,
      );
    }).toList();
  } catch (e) {
    return null;
  }
}
