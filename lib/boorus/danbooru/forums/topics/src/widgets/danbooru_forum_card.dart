// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/settings/providers.dart';
import '../../../../../../core/theme/utils.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../users/creator/providers.dart';
import '../../../../users/details/routes.dart';
import '../../../../users/user/providers.dart';
import '../../../posts/routes.dart';
import '../types/forum_topic.dart';
import 'forum_card.dart';

class DanbooruForumCard extends ConsumerWidget {
  const DanbooruForumCard({
    required this.topic,
    super.key,
  });

  final DanbooruForumTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ForumCard(
      title: topic.title,
      responseCount: topic.responseCount,
      createdAt: topic.createdAt,
      creatorInfo: Builder(
        builder: (context) {
          final creator = ref.watch(danbooruCreatorProvider(topic.creatorId));
          final creatorColor =
              DanbooruUserColor.of(context).fromLevel(creator?.level);
          final creatorName = creator?.name ?? '...';

          final colors = context.generateChipColors(
            creatorColor,
            ref.watch(enableDynamicColoringProvider),
          );

          return CompactChip(
            label: creatorName.replaceAll('_', ' '),
            backgroundColor: colors?.backgroundColor,
            textColor: colors?.foregroundColor,
            onTap: () => goToUserDetailsPage(
              context,
              uid: topic.creatorId,
            ),
          );
        },
      ),
      onTap: () => goToForumPostsPage(
        context,
        topic: topic,
      ),
    );
  }
}
