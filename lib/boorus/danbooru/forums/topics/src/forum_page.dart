// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/forums/forum_topic.dart';
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
  late final pagingController = PagingController(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: _fetchPage,
  );

  Future<List<DanbooruForumTopic>> _fetchPage(int pageKey) async {
    try {
      final config = ref.readConfigAuth;
      final creatorsNotifier = ref.read(
        danbooruCreatorsProvider(config).notifier,
      );

      final topics = await ref
          .read(danbooruForumTopicRepoProvider(config))
          .getForumTopicsOrEmpty(pageKey);

      await creatorsNotifier.load(topics.map((e) => e.creatorId).toList());

      return topics;
    } catch (e) {
      throw Exception('Failed to fetch forum topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.forum.forum),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: PagingListener(
          controller: pagingController,
          builder: (context, state, fetchNextPage) => PagedListView(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<DanbooruForumTopic>(
              itemBuilder: (context, topic, index) =>
                  DanbooruForumCard(topic: topic),
              firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
              newPageProgressIndicatorBuilder: (context) => _buildLoading(),
            ),
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
