class SearchKeywordDto {
  SearchKeywordDto({
    required this.hitCount,
    required this.keyword,
  });

  final int hitCount;
  final String keyword;

  factory SearchKeywordDto.fromJson(List<dynamic> json) => SearchKeywordDto(
        keyword: json[0],
        hitCount: json[1].toInt(),
      );

  @override
  String toString() => '$keyword: $hitCount';
}
