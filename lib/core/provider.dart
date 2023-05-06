// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';

final currentBooruConfigRepoProvider =
    Provider<CurrentBooruConfigRepository>((ref) => throw UnimplementedError());

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());

final searchHistoryRepoProvider =
    Provider<SearchHistoryRepository>((ref) => throw UnimplementedError());
