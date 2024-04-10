// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/forums/forum_card.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'danbooru_forum_posts_page.dart';

class DanbooruForumPage extends ConsumerWidget {
  const DanbooruForumPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        title: const Text('forum.forum').tr(),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RiverPagedBuilder.autoDispose(
          firstPageProgressIndicatorBuilder: (context, controller) =>
              const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          pullToRefresh: false,
          firstPageKey: 1,
          provider: danbooruForumTopicsProvider(config),
          itemBuilder: (context, topic, index) {
            final creator = ref.watch(danbooruCreatorProvider(topic.creatorId));
            final creatorName = creator?.name ?? '...';

            return ForumCard(
              title: topic.title,
              responseCount: topic.responseCount,
              createdAt: topic.createdAt,
              creatorName: creatorName,
              creatorColor: creator.getColor(context),
              onCreatorTap: () => goToUserDetailsPage(
                ref,
                context,
                uid: topic.creatorId,
                username: creatorName,
              ),
              onTap: () => context.navigator.push(CupertinoPageRoute(
                builder: (_) => DanbooruForumPostsPage(
                  topicId: topic.id,
                  title: topic.title,
                  responseCount: topic.responseCount,
                ),
              )),
            );
          },
          pagedBuilder: (controller, builder) => PagedListView(
            pagingController: controller,
            builderDelegate: builder,
          ),
        ),
      ),
    );
  }
}
