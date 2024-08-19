// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/dmails/dmails.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';
import '../home/most_search_tag_list.dart';

class LatestView extends ConsumerStatefulWidget {
  const LatestView({
    super.key,
    required this.searchBar,
  });

  final Widget searchBar;

  @override
  ConsumerState<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends ConsumerState<LatestView> {
  final _autoScrollController = AutoScrollController();
  final _selectedTag = ValueNotifier('');

  @override
  void dispose() {
    _autoScrollController.dispose();
    _selectedTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return PostScope(
      fetcher: (page) => postRepo.getPosts(_selectedTag.value, page),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
        errors: errors,
        controller: controller,
        scrollController: _autoScrollController,
        sliverHeaders: [
          SliverAppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            toolbarHeight: kToolbarHeight * 1.2,
            title: widget.searchBar,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
          const SliverAppAnnouncementBanner(),
          const SliverUnreadMailsBanner(),
          SliverToBoxAdapter(
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedTag,
              builder: (context, value, child) => MostSearchTagList(
                selected: value,
                onSelected: (search) {
                  _selectedTag.value =
                      search.keyword == value ? '' : search.keyword;
                  controller.refresh();
                  _autoScrollController.jumpTo(0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
