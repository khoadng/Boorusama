class AutocompleteDto {

  AutocompleteDto({
    this.value,
    this.alias,
    this.type,
    this.total,
    this.icon,
  });

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return AutocompleteDto(
      value: json['value'] as String?,
      alias: json['alias'] as String?,
      type: json['type'] as String?,
      total: json['total'] as int?,
      icon: json['icon'] as String?,
    );
  }
  final String? value;
  final String? alias;
  final String? type;
  final int? total;
  final String? icon;

  @override
  String toString() => value.toString();
}
