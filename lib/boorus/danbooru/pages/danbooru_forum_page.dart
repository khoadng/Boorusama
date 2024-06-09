// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/forums/forum_card.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/forums/forum_topic.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'danbooru_forum_posts_page.dart';

class DanbooruForumPage extends ConsumerStatefulWidget {
  const DanbooruForumPage({
    super.key,
  });

  @override
  ConsumerState<DanbooruForumPage> createState() => _DanbooruForumPageState();
}

class _DanbooruForumPageState extends ConsumerState<DanbooruForumPage> {
  final pagingController = PagingController<int, DanbooruForumTopic>(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    super.dispose();
    pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    final topics = await ref
        .read(danbooruForumTopicRepoProvider(ref.readConfig))
        .getForumTopicsOrEmpty(pageKey);

    await ref
        .watch(danbooruCreatorsProvider(ref.readConfig).notifier)
        .load(topics.map((e) => e.creatorId).toList());

    if (topics.isEmpty) {
      pagingController.appendLastPage([]);
    } else {
      pagingController.appendPage(topics, pageKey + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('forum.forum').tr(),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: PagedListView<int, DanbooruForumTopic>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<DanbooruForumTopic>(
            itemBuilder: (context, topic, index) =>
                _buildForumCard(context, topic),
            firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
            newPageProgressIndicatorBuilder: (context) => _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 24,
        width: 24,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Widget _buildForumCard(
    BuildContext context,
    DanbooruForumTopic topic,
  ) {
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
  }
}
