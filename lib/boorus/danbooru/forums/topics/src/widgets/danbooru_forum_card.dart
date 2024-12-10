// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../users/creator/providers.dart';
import '../../../../users/details/routes.dart';
import '../../../../users/user/providers.dart';
import '../../../posts/routes.dart';
import '../types/forum_topic.dart';
import 'forum_card.dart';

class DanbooruForumCard extends ConsumerWidget {
  const DanbooruForumCard({
    super.key,
    required this.topic,
  });

  final DanbooruForumTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = ref.watch(danbooruCreatorProvider(topic.creatorId));
    final creatorName = creator?.name ?? '...';

    return ForumCard(
      title: topic.title,
      responseCount: topic.responseCount,
      createdAt: topic.createdAt,
      creatorName: creatorName,
      creatorColor: DanbooruUserColor.of(context).fromLevel(creator?.level),
      onCreatorTap: () => goToUserDetailsPage(
        context,
        uid: topic.creatorId,
      ),
      onTap: () => goToForumPostsPage(
        context,
        topic: topic,
      ),
    );
  }
}
