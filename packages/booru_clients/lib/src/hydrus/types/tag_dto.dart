class AutocompleteDto {
  const AutocompleteDto({
    required this.value,
    required this.count,
  });

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return AutocompleteDto(
      value: json['value'] as String,
      count: json['count'] as int,
    );
  }

  final String value;
  final int count;
}
