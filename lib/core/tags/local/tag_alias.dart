class TagAlias {
  const TagAlias({
    required this.sourceSite,
    required this.sourceTag,
    required this.targetSite,
    required this.targetTag,
    required this.createdAt,
  });

  final String sourceSite;
  final String sourceTag;
  final String targetSite;
  final String targetTag;
  final DateTime createdAt;
}
