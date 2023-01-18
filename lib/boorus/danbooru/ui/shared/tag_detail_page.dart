// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({
    super.key,
    required this.tagName,
    required this.otherNamesBuilder,
    required this.backgroundImageUrl,
  });

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
    return Screen.of(context).size == ScreenSize.small
        ? Scaffold(
            appBar: AppBar(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    goToBulkDownloadPage(
                      context,
                      [widget.tagName],
                    );
                  },
                  icon: const Icon(Icons.download),
                ),
              ],
            ),
            body: Stack(children: [
              _Panel(
                tagName: widget.tagName,
                scrollController: scrollController,
                header: [
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      widget.tagName.removeUnderscoreWithSpace(),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    widget.otherNamesBuilder(context),
                  ]),
                  const SizedBox(height: 50),
                ],
              ),
            ]),
          )
        : Scaffold(
            body: Row(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Stack(children: [
                  Align(
                    alignment: const Alignment(-0.9, -0.9),
                    child: IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 70),
                      Text(
                        widget.tagName.removeUnderscoreWithSpace(),
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Expanded(child: widget.otherNamesBuilder(context)),
                    ]),
                  ),
                ]),
              ),
              const VerticalDivider(width: 3, thickness: 2),
              Expanded(
                child: _Panel(
                  useSliverAppBar: false,
                  tagName: widget.tagName,
                  scrollController: scrollController,
                ),
              ),
            ]),
          );
  }
}

class _Panel extends StatefulWidget {
  const _Panel({
    required this.tagName,
    required this.scrollController,
    this.header,
    this.useSliverAppBar = true,
  });

  final String tagName;
  final AutoScrollController scrollController;
  final List<Widget>? header;
  final bool useSliverAppBar;

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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            return InfiniteLoadListScrollView(
              isLoading: state.loading,
              scrollController: widget.scrollController,
              refreshController: refreshController,
              enableLoadMore: state.hasMore,
              onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                    tags: widget.tagName,
                    fetcher: SearchedPostFetcher.fromTags(widget.tagName),
                  )),
              onRefresh: (controller) {
                context.read<PostBloc>().add(PostRefreshed(
                      tag: widget.tagName,
                      fetcher: SearchedPostFetcher.fromTags(widget.tagName),
                    ));
                Future.delayed(
                  const Duration(milliseconds: 500),
                  () => controller.refreshCompleted(),
                );
              },
              sliverBuilder: (controller) => [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  ),
                ),
                if (widget.header != null)
                  SliverToBoxAdapter(
                    child: Column(
                      children: widget.header!,
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 10),
                  sliver: SliverToBoxAdapter(
                    child: CategoryToggleSwitch(
                      onToggle: (category) => context.read<PostBloc>().add(
                            PostRefreshed(
                              tag: widget.tagName,
                              fetcher: SearchedPostFetcher.fromTags(
                                widget.tagName,
                                order: tagFilterCategoryToPostsOrder(category),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                HomePostGrid(controller: controller),
              ],
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

PostsOrder tagFilterCategoryToPostsOrder(TagFilterCategory category) {
  if (category == TagFilterCategory.popular) return PostsOrder.popular;

  return PostsOrder.newest;
}

// ignore: prefer-single-widget-per-file
class CategoryToggleSwitch extends StatefulWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

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
            TextStyle(fontWeight: FontWeight.w700),
            TextStyle(fontWeight: FontWeight.w700),
          ],
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 100,
          minHeight: 30,
          cornerRadius: 5,
          labels: [
            'tag.explore.new'.tr(),
            'tag.explore.popular'.tr(),
          ],
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
