// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/dmails/dmails.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import '../home/most_search_tag_list.dart';

class LatestView extends ConsumerStatefulWidget {
  const LatestView({
    super.key,
    required this.controller,
  });

  final HomePageController controller;

  @override
  ConsumerState<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends ConsumerState<LatestView> {
  final _autoScrollController = AutoScrollController();
  final _selectedMostSearchedTag = ValueNotifier('');
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.read(currentBooruBuilderProvider),
    tagInfo: ref.read(tagInfoProvider),
  );

  @override
  void dispose() {
    _autoScrollController.dispose();
    _selectedMostSearchedTag.dispose();
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return PostScope(
      fetcher: (page) {
        return context.isLargeScreen
            ? postRepo.getPostsFromController(
                selectedTagController,
                page,
              )
            : postRepo.getPosts(
                _selectedMostSearchedTag.value,
                page,
              );
      },
      builder: (context, controller) => PostGrid(
        controller: controller,
        scrollController: _autoScrollController,
        itemBuilder:
            (context, index, multiSelectController, scrollController) =>
                DefaultDanbooruImageGridItem(
          index: index,
          multiSelectController: multiSelectController,
          autoScrollController: scrollController,
          controller: controller,
        ),
        sliverHeaders: [
          SliverHomeSearchBar(
            selectedTagController: selectedTagController,
            controller: widget.controller,
            selectedTagString: selectedTagString,
            onSearch: () {
              controller.refresh();
            },
          ),
          const SliverAppAnnouncementBanner(),
          const SliverUnreadMailsBanner(),
          if (context.isLargeScreen)
            SliverResultHeader(
              selectedTagString: selectedTagString,
              controller: controller,
            ),
          if (!context.isLargeScreen)
            SliverToBoxAdapter(
              child: ValueListenableBuilder<String>(
                valueListenable: _selectedMostSearchedTag,
                builder: (context, value, child) => MostSearchTagList(
                  selected: value,
                  onSelected: (search, sel) {
                    _selectedMostSearchedTag.value =
                        search.keyword == value ? '' : search.keyword;

                    selectedTagString.value = search.keyword;
                    if (sel) {
                      selectedTagController.clear();
                      selectedTagController.addTag(search.keyword);
                    } else {
                      selectedTagController.clear();
                    }
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

  var selectedTagString = ValueNotifier('');
}
