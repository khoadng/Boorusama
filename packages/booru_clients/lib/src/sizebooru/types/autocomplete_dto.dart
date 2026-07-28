class SizebooruAutocompleteDto {
  SizebooruAutocompleteDto({
    required this.value,
    this.label,
    this.postCount,
  });

  final String value;
  final String? label;
  final int? postCount;
}
