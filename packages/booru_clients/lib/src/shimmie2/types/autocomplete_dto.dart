class AutocompleteDto {
  AutocompleteDto({
    this.value,
    this.count,
  });

  final String? value;
  final int? count;

  @override
  String toString() => '$value: $count';
}
