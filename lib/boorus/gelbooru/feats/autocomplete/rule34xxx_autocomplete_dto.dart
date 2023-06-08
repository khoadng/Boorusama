class Rule34xxxAutocompleteDto {
  Rule34xxxAutocompleteDto({
    required this.type,
    required this.label,
    required this.value,
  });

  factory Rule34xxxAutocompleteDto.fromJson(Map<String, dynamic> json) {
    return Rule34xxxAutocompleteDto(
      type: json['type'],
      label: json['label'],
      value: json['value'],
    );
  }

  final String? type;
  final String? label;
  final String? value;
}
