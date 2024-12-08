// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/forums/forum_post.dart';
import '../../users/creator/creators_notifier.dart';
import 'converter.dart';
import 'forum_post.dart';

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

      final data = value.map(danbooruForumPostDtoToDanbooruForumPost).toList();

      data.sort((a, b) => a.id.compareTo(b.id));

      ref.read(danbooruCreatorsProvider(config).notifier).load(
            {
              ...data.map((e) => e.creatorId),
              ...data.expand((e) => e.votes).map((e) => e.creatorId),
            }.toList(),
          );

      return data;
    },
  );
});

class DanbooruForumUtils {
  const DanbooruForumUtils._();

  static const int postPerPage = 20;

  static int getFirstPageKey({
    required int responseCount,
  }) =>
      (responseCount / postPerPage).ceil();
}
