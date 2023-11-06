// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';

final searchHistoryRepoProvider =
    Provider<SearchHistoryRepository>((ref) => throw UnimplementedError());

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, SearchHistoryState>(
        SearchHistoryNotifier.new);
