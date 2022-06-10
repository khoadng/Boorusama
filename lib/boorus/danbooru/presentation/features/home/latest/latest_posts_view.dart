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
import 'package:boorusama/boorus/danbooru/application/home/lastest/tag_list.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_chips_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class LatestView extends StatefulWidget {
  const LatestView({
    Key? key,
    required this.onMenuTap,
  }) : super(key: key);

  final VoidCallback onMenuTap;

  @override
  State<LatestView> createState() => _LatestViewState();
}

class _LatestViewState extends State<LatestView> {
  final AutoScrollController _autoScrollController = AutoScrollController();
  final ValueNotifier<String> _selectedTag = ValueNotifier('');
  final BehaviorSubject<String> _selectedTagStream = BehaviorSubject();
  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  void _sendRefresh(String tag) =>
      context.read<PostBloc>().add(PostRefreshed(tag: tag));

  @override
  void initState() {
    super.initState();
    _selectedTag.addListener(() => _selectedTagStream.add(_selectedTag.value));

    _selectedTagStream
        .debounceTime(const Duration(milliseconds: 500))
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
    return InfiniteLoadList2(
      extendBody: true,
      onLoadMore: () =>
          context.read<PostBloc>().add(PostFetched(tags: _selectedTag.value)),
      onRefresh: (controller) {
        _sendRefresh(_selectedTag.value);
        Future.delayed(
            const Duration(seconds: 1), () => controller.refreshCompleted());
      },
      scrollController: _autoScrollController,
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          _buildAppBar(context),
          _buildMostSearchTagList(),
          SliverPostImageGrid(controller: controller),
          _buildBottomIndicator(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight * 1.2,
      title: SearchBar(
        enabled: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.onMenuTap(),
        ),
        onTap: () => AppRouter.router.navigateTo(context, "/posts/search",
            routeSettings: const RouteSettings(arguments: [''])),
      ),
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildMostSearchTagList() {
    return BlocBuilder<SearchKeywordCubit, AsyncLoadState<List<Search>>>(
      builder: (context, state) => SliverToBoxAdapter(
        child: mapStateToTagList(state),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => current.status == PostStatus.loading,
        builder: (context, state) {
          return const SliverPadding(
            padding: EdgeInsets.only(
                bottom: kBottomNavigationBarHeight + 20, top: 20),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }

  Widget mapStateToTagList(AsyncLoadState<List<Search>> state) {
    switch (state.status) {
      case LoadStatus.success:
        return _buildTags(state.data!);
      case LoadStatus.failure:
        return const SizedBox.shrink();
      default:
        return const TagChipsPlaceholder();
    }
  }

  Widget _buildTags(List<Search> searches) {
    return ValueListenableBuilder(
      valueListenable: _selectedTag,
      builder: (context, selectedTag, child) => Container(
        margin: const EdgeInsets.only(left: 8.0),
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final selected = selectedTag == searches[index].keyword;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                selectedColor: Colors.white,
                selected: selected,
                onSelected: (selected) => selected
                    ? _selectedTag.value = searches[index].keyword
                    : _selectedTag.value = "",
                padding: const EdgeInsets.all(4.0),
                labelPadding: const EdgeInsets.all(1.0),
                visualDensity: VisualDensity.compact,
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85),
                  child: Text(
                    searches[index].keyword.removeUnderscoreWithSpace(),
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SliverPostImageGrid extends StatelessWidget {
  const SliverPostImageGrid({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AutoScrollController controller;

  Widget mapStateToWidget(BuildContext context, PostState state) {
    if (state.status == PostStatus.initial) {
      return const SliverPostGridPlaceHolder();
    } else if (state.status == PostStatus.success) {
      return SliverPostGrid(
        posts: state.posts,
        scrollController: controller,
        onTap: (post, index) => AppRouter.router.navigateTo(
          context,
          "/post/detail",
          routeSettings: RouteSettings(
            arguments: [
              state.posts,
              index,
              controller,
            ],
          ),
        ),
      );
    } else if (state.status == PostStatus.loading) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    } else {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text("Something went wrong"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      sliver: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => current.status != PostStatus.loading,
        builder: mapStateToWidget,
      ),
    );
  }
}
