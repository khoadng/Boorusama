// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'forum_card.dart';

class DanbooruForumPage extends ConsumerWidget {
  const DanbooruForumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RiverPagedBuilder.autoDispose(
        firstPageProgressIndicatorBuilder: (context, controller) =>
            const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        pullToRefresh: false,
        firstPageKey: 1,
        provider: danbooruForumTopicsProvider,
        itemBuilder: (context, topic, index) => ForumCard(
          title: topic.title,
          responseCount: topic.responseCount,
          createdAt: topic.createdAt,
          creatorName: topic.creator.name,
          creatorColor: topic.creator.level.toColor(),
        ),
        pagedBuilder: (controller, builder) => PagedListView(
          pagingController: controller,
          builderDelegate: builder,
        ),
      ),
    );
  }
}
