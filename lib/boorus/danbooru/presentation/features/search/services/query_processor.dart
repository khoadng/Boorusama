class QueryProcessor {
  String process(
      String currentQuery, String lastQuery, List<String> completedQueries) {
    final removeMode = currentQuery.length < lastQuery.length;
    String currentInputQuery;
    final queryItems = completedQueries;
    final queries = currentQuery.split(' ');

    if (!currentQuery.endsWith(' ')) {
      currentInputQuery = queries.last;
    } else {
      currentInputQuery = '';

      if (removeMode) {
        queryItems.removeLast();
      } else {
        queryItems.add(currentQuery.trim().split(' ').last);
      }
    }
    return currentInputQuery;
  }
}
