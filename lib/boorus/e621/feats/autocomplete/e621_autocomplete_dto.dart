class E621AutocompleteDto {
  E621AutocompleteDto({
    this.id,
    this.name,
    this.postCount,
    this.category,
    this.antecedentName,
  });

  final int? id;
  final String? name;
  final int? postCount;
  final int? category;
  final String? antecedentName;

  factory E621AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return E621AutocompleteDto(
      id: json['id'],
      name: json['name'],
      postCount: json['post_count'],
      category: json['category'],
      antecedentName: json['antecedent_name'],
    );
  }
}
