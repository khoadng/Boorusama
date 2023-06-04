// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'post_count_state.dart';
import 'posts_provider.dart';

String generatePostCountKey(List<String> tags) => tags.join('+');

class PostCountNotifier extends Notifier<PostCountState> {
  PostCountNotifier({
    this.cacheDuration = const Duration(minutes: 1),
  }) : super();

  final Duration cacheDuration;

  // Store timestamps for cache keys
  final Map<String, DateTime> _postCountTimestamps = {};

  @override
  PostCountState build() {
    return PostCountState.initial();
  }

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

      final postCount = await ref.read(postCountRepoProvider).count(tags);
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
