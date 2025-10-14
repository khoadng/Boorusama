// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/forums/forum_topic.dart';
import '../../../../client_provider.dart';
import '../types/forum_topic.dart';
import 'converter.dart';

final danbooruForumTopicRepoProvider =
    Provider.family<ForumTopicRepository<DanbooruForumTopic>, BooruConfigAuth>((
      ref,
      config,
    ) {
      final client = ref.watch(danbooruClientProvider(config));

      return ForumTopicRepositoryBuilder(
        fetch: (page) => client
            .getForumTopics(
              order: TopicOrder.sticky,
              page: page,
              limit: 50,
            )
            .then(
              (value) => value.map((dto) => dtoToTopic(dto)).toList(),
            ),
      );
    });
