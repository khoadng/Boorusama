class AutocompleteDto {
  AutocompleteDto({
    required this.type,
    required this.label,
    required this.value,
    required this.postCount,
    required this.category,
  });

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) {
    int? postCount;
    var label = json['label'];

    if (json['post_count'] != null) {
      postCount = int.tryParse(json['post_count']);
    } else if (json['label'] != null) {
      final (c, l) = extractDataFromTagLabel(json['label']);
      postCount = c;
      label = l;
    }

    return AutocompleteDto(
      type: json['type'],
      label: label?.replaceAll('_', ' '),
      value: json['value'],
      postCount: postCount,
      category: json['category'] ?? json['type'],
    );
  }

  final String? type;
  final String? label;
  final String? value;
  final int? postCount;
  final String? category;

  @override
  String toString() => value ?? '';
}

(int count, String label) extractDataFromTagLabel(String input) {
  // extract data from tag label e.g abc (40) -> (40, abc)
  final match = RegExp(r'(.*) \((\d+)\)').firstMatch(input);

  if (match == null) {
    throw Exception('can\'t parse tag label');
  }

  final count = int.parse(match.group(2)!);
  final label = match.group(1)!;

  return (count, label);
}
