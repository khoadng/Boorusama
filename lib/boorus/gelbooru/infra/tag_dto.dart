class TagDto {
  TagDto({
    required this.id,
    required this.name,
    required this.count,
    required this.type,
    required this.ambiguous,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      type: json['type'],
      ambiguous: json['ambiguous'],
    );
  }

  final int? id;
  final String? name;
  final int? count;
  final int? type;
  final int? ambiguous;
}
