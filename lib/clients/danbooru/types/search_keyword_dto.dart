class SearchKeywordDto {
  SearchKeywordDto({
    required this.hitCount,
    required this.keyword,
  });

  factory SearchKeywordDto.fromJson(List<dynamic> json) => SearchKeywordDto(
        keyword: json[0],
        hitCount: json[1].toInt(),
      );

  final int hitCount;
  final String keyword;

  @override
  String toString() => '$keyword: $hitCount';
}
