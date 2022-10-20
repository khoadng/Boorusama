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
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';

class LatestView extends StatefulWidget {
  const LatestView({
    Key? key,
    this.onMenuTap,
  }) : super(key: key);

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
        .debounceTime(const Duration(milliseconds: 350))
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
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) => !current.hasMore,
      builder: (context, state) {
        return InfiniteLoadList(
          extendBody: Screen.of(context).size == ScreenSize.small,
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
          builder: (context, controller) => CustomScrollView(
            controller: controller,
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 2),
                sliver: _buildMostSearchTagList(),
              ),
              HomePostGrid(
                controller: controller,
              ),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  return state.status == LoadStatus.loading
                      ? const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          sliver: SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SearchBar(
              enabled: false,
              leading: widget.onMenuTap != null
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => widget.onMenuTap!(),
                    )
                  : null,
              onTap: () => AppRouter.router.navigateTo(
                context,
                '/posts/search',
                routeSettings: const RouteSettings(arguments: ['']),
              ),
            ),
          ),
          if (isDesktopPlatform())
            MaterialButton(
              color: Theme.of(context).cardColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              onPressed: () => context.read<PostBloc>().add(const PostRefreshed(
                    fetcher: LatestPostFetcher(),
                  )),
              child: const Icon(Icons.refresh),
            ),
        ],
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

  Widget mapStateToTagList(AsyncLoadState<List<Search>> state) {
    switch (state.status) {
      case LoadStatus.success:
        return ConditionalRenderWidget(
          condition: state.data!.isNotEmpty,
          childBuilder: (context) => _buildTags(state.data!),
        );
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
        margin: const EdgeInsets.only(left: 8),
        height: 50,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final selected = selectedTag == searches[index].keyword;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                disabledColor: Theme.of(context).chipTheme.disabledColor,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                selected: selected,
                onSelected: (selected) => selected
                    ? _selectedTag.value = searches[index].keyword
                    : _selectedTag.value = '',
                padding: const EdgeInsets.all(4),
                labelPadding: const EdgeInsets.all(1),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).hintColor,
                ),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Text(
                    searches[index].keyword.removeUnderscoreWithSpace(),
                    overflow: TextOverflow.fade,
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
