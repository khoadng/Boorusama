// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_forums.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/forums/forum_topic.dart';
import 'forum_topic.dart';

final danbooruForumTopicRepoProvider =
    Provider.family<ForumTopicRepository<DanbooruForumTopic>, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return ForumTopicRepositoryBuilder(
    fetch: (page) => client
        .getForumTopics(
          order: TopicOrder.sticky,
          page: page,
          limit: 50,
        )
        .then(
          (value) => value
              .map((dto) => DanbooruForumTopic(
                    id: dto.id ?? 0,
                    creatorId: dto.creatorId ?? 0,
                    updaterId: dto.updaterId ?? 0,
                    title: dto.title ?? '',
                    responseCount: dto.responseCount ?? 0,
                    isSticky: dto.isSticky ?? false,
                    isLocked: dto.isLocked ?? false,
                    createdAt: dto.createdAt != null
                        ? DateTime.parse(dto.createdAt!)
                        : DateTime.now(),
                    updatedAt: dto.updatedAt != null
                        ? DateTime.parse(dto.updatedAt!)
                        : DateTime.now(),
                    isDeleted: dto.isDeleted ?? false,
                    category: dto.categoryId != null
                        ? intToDanbooruTopicCategory(dto.categoryId!)
                        : DanbooruTopicCategory.general,
                  ))
              .toList(),
        ),
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
