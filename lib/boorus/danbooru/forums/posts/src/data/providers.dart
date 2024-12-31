// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/forums/forum_post.dart';
import '../../../../danbooru_provider.dart';
import '../../../../users/creator/providers.dart';
import '../types/forum_post.dart';
import 'converter.dart';

final danbooruForumPostRepoProvider = Provider.family<
    ForumPostRepositoryBuilder<DanbooruForumPost>,
    BooruConfigAuth>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  // page is the last forum post id
  return ForumPostRepositoryBuilder(
    fetch: (topicId, {required page, limit}) async {
      final value = await client.getForumPosts(
        topicId: topicId,
        page: page.toString(),
        limit: limit,
      );

      final data = value.map(danbooruForumPostDtoToDanbooruForumPost).toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      unawaited(
        ref.read(danbooruCreatorsProvider(config).notifier).load(
              {
                ...data.map((e) => e.creatorId),
                ...data.expand((e) => e.votes).map((e) => e.creatorId),
              }.toList(),
            ),
      );

      return data;
    },
  );
});
