// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_forums.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/forums/forums.dart';

final danbooruForumTopicRepoProvider =
    Provider.family<ForumTopicRepository<DanbooruForumTopic>, BooruConfig>(
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

final danbooruForumPostRepoProvider =
    Provider.family<ForumPostRepositoryBuilder<DanbooruForumPost>, BooruConfig>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  // page is the last forum post id
  return ForumPostRepositoryBuilder(
    fetch: (topicId, {required page, limit}) async {
      final value = await client.getForumPosts(
        topicId: topicId,
        page: page.toString(),
        limit: limit,
      );

      var data = value.map(danbooruForumPostDtoToDanbooruForumPost).toList();

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
