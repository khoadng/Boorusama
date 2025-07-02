class TagSummary {
  TagSummary({
    required this.category,
    required this.name,
    required this.otherNames,
  });
  final int category;
  final String name;
  final List<String> otherNames;
}

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
