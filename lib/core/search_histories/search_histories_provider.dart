// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/search_histories/search_histories.dart';

final searchHistoryRepoProvider =
    Provider<SearchHistoryRepository>((ref) => throw UnimplementedError());

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, SearchHistoryState>(
        SearchHistoryNotifier.new);
