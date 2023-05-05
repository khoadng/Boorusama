import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String generatePostCountKey(List<String> tags) => tags.join('+');

class PostCountNotifier extends StateNotifier<PostCountState> {
  final PostCountRepository repository;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final BooruFactory booruFactory;
  final Duration cacheDuration;

  // Store timestamps for cache keys
  final Map<String, DateTime> _postCountTimestamps = {};

  PostCountNotifier({
    required this.repository,
    required this.currentBooruConfigRepository,
    required this.booruFactory,
    this.cacheDuration = const Duration(minutes: 1),
  }) : super(PostCountState.initial());

  Future<void> getPostCount(List<String> tags) async {
    try {
      final cacheKey = generatePostCountKey(tags);

      // Check if the cache is still valid.
      final cacheTimestamp = _postCountTimestamps[cacheKey];
      if (cacheTimestamp != null &&
          DateTime.now().difference(cacheTimestamp) < cacheDuration &&
          state.postCounts.containsKey(cacheKey)) {
        return;
      }

      final config = await currentBooruConfigRepository.get();
      if (config == null) return;

      final newTags = [
        ...tags,
        //TODO: this is a hack to get around the fact that count endpoint includes all ratings
        if (config.createBooruFrom(booruFactory).booruType ==
            BooruType.safebooru)
          'rating:general',
      ];

      final postCount = await repository.count(newTags);
      state = PostCountState({
        ...state.postCounts,
        cacheKey: postCount,
      });

      // Update the timestamp for the cache key
      _postCountTimestamps[cacheKey] = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
