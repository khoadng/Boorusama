class Search {
  Search({
    required this.hitCount,
    required this.keyword,
  });

  final int hitCount;
  final String keyword;
}

abstract class PopularSearchRepository {
  Future<List<Search>> getSearchByDate(DateTime date);
}
