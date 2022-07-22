// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({
    Key? key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
  }) : super(key: key);

  final String tagName;
  final String backgroundImageUrl;
  final Widget Function(BuildContext context) otherNamesBuilder;

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  final AutoScrollController scrollController = AutoScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 24;

    return Scaffold(
      body: SlidingUpPanel(
        scrollController: scrollController,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        maxHeight: height,
        minHeight: height * 0.55,
        panelBuilder: (_) => _Panel(
          tagName: widget.tagName,
          scrollController: scrollController,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.backgroundImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black.withOpacity(0.6)],
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.tagName.removeUnderscoreWithSpace(),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                  ),
                  widget.otherNamesBuilder(context),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0.8, -0.85),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatefulWidget {
  const _Panel({
    Key? key,
    required this.tagName,
    required this.scrollController,
  }) : super(key: key);

  final String tagName;
  final AutoScrollController scrollController;

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  final RefreshController refreshController = RefreshController();

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: BlocBuilder<PostBloc, PostState>(
          buildWhen: (previous, current) => !current.hasMore,
          builder: (context, state) {
            return InfiniteLoadList(
              scrollController: widget.scrollController,
              refreshController: refreshController,
              enableLoadMore: state.hasMore,
              onLoadMore: () => context
                  .read<PostBloc>()
                  .add(PostFetched(tags: widget.tagName)),
              onRefresh: (controller) {
                context
                    .read<PostBloc>()
                    .add(PostRefreshed(tag: widget.tagName));
                Future.delayed(const Duration(milliseconds: 500),
                    () => controller.refreshCompleted());
              },
              builder: (context, controller) => CustomScrollView(
                controller: controller,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 10),
                    sliver: SliverToBoxAdapter(
                      child: CategoryToggleSwitch(
                        onToggle: (category) => context.read<PostBloc>().add(
                              PostRefreshed(
                                tag: widget.tagName,
                                order: _tagFilterCategoryToPostsOrder(category),
                              ),
                            ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: BlocBuilder<PostBloc, PostState>(
                      buildWhen: (previous, current) =>
                          current.status != LoadStatus.loading,
                      builder: (context, state) {
                        if (state.status == LoadStatus.initial) {
                          return const SliverPostGridPlaceHolder();
                        } else if (state.status == LoadStatus.success) {
                          if (state.posts.isEmpty) {
                            return const SliverToBoxAdapter(
                                child: Center(child: Text('No data')));
                          }
                          return SliverPostGrid(
                            posts: state.posts,
                            scrollController: controller,
                            onTap: (post, index) => AppRouter.router.navigateTo(
                              context,
                              '/post/detail',
                              routeSettings: RouteSettings(
                                arguments: [
                                  state.posts,
                                  index,
                                  controller,
                                ],
                              ),
                            ),
                          );
                        } else if (state.status == LoadStatus.loading) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        } else {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Text('Something went wrong'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state.status == LoadStatus.loading) {
                        return const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20, top: 20),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum TagFilterCategory {
  popular,
  newest,
}

PostsOrder _tagFilterCategoryToPostsOrder(TagFilterCategory category) {
  if (category == TagFilterCategory.popular) return PostsOrder.popular;
  return PostsOrder.newest;
}

class CategoryToggleSwitch extends StatefulWidget {
  const CategoryToggleSwitch({
    Key? key,
    required this.onToggle,
  }) : super(key: key);

  final void Function(TagFilterCategory category) onToggle;

  @override
  State<CategoryToggleSwitch> createState() => _CategoryToggleSwitchState();
}

class _CategoryToggleSwitchState extends State<CategoryToggleSwitch> {
  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) => ToggleSwitch(
          customTextStyles: const [
            TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            TextStyle(fontWeight: FontWeight.w700),
          ],
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 80,
          minHeight: 30,
          cornerRadius: 5,
          labels: const ['New', 'Popular'],
          activeBgColor: [Theme.of(context).colorScheme.primary],
          inactiveBgColor: Theme.of(context).colorScheme.background,
          borderWidth: 1,
          borderColor: [Theme.of(context).hintColor],
          onToggle: (index) {
            index == 0
                ? widget.onToggle(TagFilterCategory.newest)
                : widget.onToggle(TagFilterCategory.popular);

            selected.value = index ?? 0;
          },
        ),
      ),
    );
  }
}

class TagOtherNames extends StatelessWidget {
  const TagOtherNames({
    Key? key,
    required this.otherNames,
  }) : super(key: key);

  final List<String> otherNames;

  @override
  Widget build(BuildContext context) {
    return Tags(
      heightHorizontalScroll: 40,
      spacing: 2,
      horizontalScroll: true,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      itemCount: otherNames.length,
      itemBuilder: (index) {
        return Chip(
          shape: const StadiumBorder(side: BorderSide(color: Colors.grey)),
          padding: const EdgeInsets.all(4),
          labelPadding: const EdgeInsets.all(1),
          visualDensity: VisualDensity.compact,
          label: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              otherNames[index].removeUnderscoreWithSpace(),
              overflow: TextOverflow.fade,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
