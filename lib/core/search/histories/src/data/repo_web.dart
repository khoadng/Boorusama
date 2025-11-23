// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/search_history_repository.dart';
import 'repo_empty.dart';

const kSearchHistoryDbName = 'search_history.db';

final searchHistoryRepoProvider = FutureProvider<SearchHistoryRepository>(
  (ref) {
    return EmptySearchHistoryRepository();
  },
);

Future<String> getSearchHistoryDbPath() async {
  return '';
}
