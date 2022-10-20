class RelatedTagDto {
  const RelatedTagDto({
    required this.query,
    required this.category,
    required this.tags,
  });

  factory RelatedTagDto.fromJson(Map<String, dynamic> json) => RelatedTagDto(
        query: json['query'],
        category: json['category'],
        tags: List<List<dynamic>>.from(
          json['tags'].map((x) => List<dynamic>.from(x.map((x) => x))),
        ),
      );

  final String query;
  final dynamic category;
  final List<List<dynamic>> tags;
}
