// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';
import 'most_search_tag_list.dart';

class LatestViewDesktop extends StatefulWidget {
  const LatestViewDesktop({
    super.key,
  });

  @override
  State<LatestViewDesktop> createState() => _LatestViewDesktopState();
}

class _LatestViewDesktopState extends State<LatestViewDesktop> {
  final AutoScrollController _autoScrollController = AutoScrollController();
  final ValueNotifier<String> _selectedTag = ValueNotifier('');
  final BehaviorSubject<String> _selectedTagStream = BehaviorSubject();
  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  void _sendRefresh(String tag) => context.read<PostBloc>().add(PostRefreshed(
        tag: tag,
        fetcher: SearchedPostFetcher.fromTags(tag),
      ));

  @override
  void initState() {
    super.initState();
    _selectedTag.addListener(() => _selectedTagStream.add(_selectedTag.value));

    _selectedTagStream
        .debounceTime(const Duration(milliseconds: 250))
        .distinct()
        .listen(_sendRefresh)
        .addTo(_compositeSubscription);
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    _compositeSubscription.dispose();
    _selectedTagStream.close();
    _selectedTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostBloc>().state;

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              const Spacer(),
              ButtonBar(
                buttonPadding: EdgeInsets.zero,
                children: [
                  _ToolbarButton(
                    onPressed: () => goToSearchPage(context),
                    child: const Icon(Icons.search),
                  ),
                  _ToolbarButton(
                    onPressed: () =>
                        context.read<PostBloc>().add(const PostRefreshed(
                              fetcher: LatestPostFetcher(),
                            )),
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 8,
          thickness: 2,
        ),
        ValueListenableBuilder<String>(
          valueListenable: _selectedTag,
          builder: (context, value, child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _MostSearchTagSection(
              selected: value,
              onSelected: (search) {
                _selectedTag.value =
                    search.keyword == value ? '' : search.keyword;
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InfiniteLoadListScrollView(
              isLoading: state.loading,
              enableLoadMore: state.hasMore,
              onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                    tags: _selectedTag.value,
                    fetcher: const LatestPostFetcher(),
                  )),
              onRefresh: (controller) {
                _sendRefresh(_selectedTag.value);
                Future.delayed(
                  const Duration(seconds: 1),
                  () => controller.refreshCompleted(),
                );
              },
              scrollController: _autoScrollController,
              sliverBuilder: (controller) => [
                HomePostGrid(
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MaterialButton(
        minWidth: 0,
        color: Theme.of(context).cardColor,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}

class _MostSearchTagSection extends StatelessWidget {
  const _MostSearchTagSection({
    required this.onSelected,
    required this.selected,
  });

  final void Function(Search search) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((SearchKeywordCubit cubit) => cubit.state.status);

    switch (status) {
      case LoadStatus.success:
        return MostSearchTagList(
          onSelected: onSelected,
          selected: selected,
        );
      case LoadStatus.failure:
        return const SizedBox.shrink();
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const TagChipsPlaceholder();
    }
  }
}
