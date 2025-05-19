// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../core/boorus/engine/providers.dart';
import '../../../../core/configs/ref.dart';
import '../../../../core/foundation/display.dart';
import '../../../../core/home/home_search_bar.dart';
import '../../../../core/posts/count/widgets.dart';
import '../../../../core/posts/listing/widgets.dart';
import '../../../../core/search/selected_tags/providers.dart';
import '../../../../core/settings/providers.dart';
import '../../../../core/settings/settings.dart';
import '../../../../core/tags/configs/providers.dart';
import '../../dmails/widgets.dart';
import '../../posts/listing/widgets.dart';
import '../../posts/post/providers.dart';
import 'most_search_tag_list.dart';

class LatestView extends ConsumerStatefulWidget {
  const LatestView({
    super.key,
  });

  @override
  ConsumerState<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends ConsumerState<LatestView> {
  final _autoScrollController = AutoScrollController();
  final _selectedMostSearchedTag = ValueNotifier('');
  late final SelectedTagController selectedTagController;

  @override
  void initState() {
    super.initState();

    selectedTagController = SelectedTagController.fromBooruBuilder(
      builder: ref.read(booruBuilderProvider(ref.readConfigAuth)),
      tagInfo: ref.read(tagInfoProvider),
    );
  }

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
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return PostScope(
      fetcher: (page) {
        return context.isLargeScreen
            ? postRepo.getPostsFromController(
                selectedTagController.tagSet,
                page,
              )
            : postRepo.getPosts(
                _selectedMostSearchedTag.value,
                page,
              );
      },
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: PostGrid(
              controller: controller,
              scrollController: _autoScrollController,
              itemBuilder: (
                context,
                index,
                multiSelectController,
                scrollController,
                hero,
              ) =>
                  DefaultDanbooruImageGridItem(
                index: index,
                multiSelectController: multiSelectController,
                autoScrollController: scrollController,
                controller: controller,
              ),
              sliverHeaders: [
                if (context.isLargeScreen ||
                    searchBarPosition == SearchBarPosition.top)
                  SliverHomeSearchBar(
                    selectedTagController: selectedTagController,
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
                            selectedTagController
                              ..clear()
                              ..addTag(search.keyword);
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
          ),
          if (searchBarPosition == SearchBarPosition.bottom &&
              !context.isLargeScreen)
            Consumer(
              builder: (_, ref, __) {
                final position = ref.watch(
                  settingsProvider
                      .select((value) => value.booruConfigSelectorPosition),
                );

                return SafeArea(
                  top: false,
                  bottom: position != BooruConfigSelectorPosition.bottom,
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: CustomScrollView(
                      slivers: [
                        SliverHomeSearchBar(
                          primary: false,
                          selectedTagController: selectedTagController,
                          selectedTagString: selectedTagString,
                          onSearch: () {
                            controller.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  var selectedTagString = ValueNotifier('');
}
