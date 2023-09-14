class GelbooruV0Dot2AutocompleteDto {
  GelbooruV0Dot2AutocompleteDto({
    required this.label,
    required this.value,
  });

  factory GelbooruV0Dot2AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return GelbooruV0Dot2AutocompleteDto(
      label: json['label'],
      value: json['value'],
    );
  }

  final String? label;
  final String? value;
}
