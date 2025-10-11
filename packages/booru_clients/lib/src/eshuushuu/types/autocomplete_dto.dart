import 'dart:convert';

class AutocompleteDto {
  AutocompleteDto({
    required this.value,
  });

  factory AutocompleteDto.fromString(String value) => AutocompleteDto(
    value: value,
  );

  final String value;

  @override
  String toString() => value;
}

List<AutocompleteDto> parseAutocomplete(String response) {
  final lines = response.trim().split('\n');
  return lines.where((line) => line.isNotEmpty).map((line) {
    // Each line is a JSON string like "activewear"
    final decoded = jsonDecode(line) as String;
    return AutocompleteDto.fromString(decoded);
  }).toList();
}
