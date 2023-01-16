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
import 'package:boorusama/core/ui/search_bar.dart';
import 'most_search_tag_list.dart';

class LatestView extends StatefulWidget {
  const LatestView({
    super.key,
    this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  State<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends State<LatestView> {
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
        .listen((tag) {
      _autoScrollController.jumpTo(0);
      _sendRefresh(tag);
    }).addTo(_compositeSubscription);
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

    return InfiniteLoadListScrollView(
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
        _AppBar(onMenuTap: widget.onMenuTap),
        SliverToBoxAdapter(
          child: ValueListenableBuilder<String>(
            valueListenable: _selectedTag,
            builder: (context, value, child) => _MostSearchTagSection(
              selected: value,
              onSelected: (search) {
                _selectedTag.value =
                    search.keyword == value ? '' : search.keyword;
              },
            ),
          ),
        ),
        HomePostGrid(
          controller: controller,
        ),
      ],
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

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: kToolbarHeight * 1.2,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SearchBar(
              enabled: false,
              leading: onMenuTap != null
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => onMenuTap!(),
                    )
                  : null,
              onTap: () => goToSearchPage(context),
            ),
          ),
        ],
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }
}
