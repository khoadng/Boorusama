// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/forums/forum_topic.dart';
import '../../../users/creator/providers.dart';
import 'data/providers.dart';
import 'types/forum_topic.dart';
import 'widgets/danbooru_forum_card.dart';

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
    final config = ref.readConfigAuth;

    final topics = await ref
        .read(danbooruForumTopicRepoProvider(config))
        .getForumTopicsOrEmpty(pageKey);

    await ref
        .watch(danbooruCreatorsProvider(config).notifier)
        .load(topics.map((e) => e.creatorId).toList());

    if (!mounted) return;

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
                DanbooruForumCard(topic: topic),
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
}
