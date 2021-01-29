// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/explore/explore_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/list_item_status.dart';
import 'package:boorusama/generated/i18n.dart';

final _posts = Provider<List<Post>>((ref) {
  return ref.watch(exploreStateNotifierProvider.state).posts.items;
});
final _curatedPostProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(exploreStateNotifierProvider.state).posts.status;
});
final _postsStateProvider = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(_postsState);
});

final _timeScale = Provider<TimeScale>((ref) {
  return ref.watch(exploreStateNotifierProvider.state).selectedTimeScale;
});
final _timeScaleProvider = Provider<TimeScale>((ref) {
  final timeScale = ref.watch(_timeScale);

  Future.delayed(
      Duration.zero, () => ref.watch(exploreStateNotifierProvider).refresh());

  return timeScale;
});

final _date = Provider<DateTime>((ref) {
  return ref.watch(exploreStateNotifierProvider.state).selectedDate;
});
final _dateProvider = Provider<DateTime>((ref) {
  final date = ref.watch(_date);

  Future.delayed(
      Duration.zero, () => ref.watch(exploreStateNotifierProvider).refresh());

  return date;
});

final _category = Provider<ExploreCategory>((ref) {
  return ref.watch(exploreStateNotifierProvider.state).category;
});
final _categoryProvider = Provider<ExploreCategory>((ref) {
  return ref.watch(_category);
});

final _lastViewedPostIndex = Provider<int>((ref) {
  return ref
      .watch(exploreStateNotifierProvider.state)
      .posts
      .lastViewedItemIndex;
});
final _lastViewedPostIndexProvider = Provider<int>((ref) {
  final lastViewedPost = ref.watch(_lastViewedPostIndex);
  return lastViewedPost;
});

class ExplorePage extends HookWidget {
  const ExplorePage({Key key}) : super(key: key);

  Widget _buildModalTimeScalePicker(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(I18n.of(context).dateRangeDay),
              onTap: () => Navigator.of(context).pop(TimeScale.day),
            ),
            ListTile(
              title: Text(I18n.of(context).dateRangeWeek),
              onTap: () => Navigator.of(context).pop(TimeScale.week),
            ),
            ListTile(
              title: Text(I18n.of(context).dateRangeMonth),
              onTap: () => Navigator.of(context).pop(TimeScale.month),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalCategoryPicker(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(I18n.of(context).postCategoriesPopular),
              onTap: () => Navigator.of(context).pop(ExploreCategory.popular()),
            ),
            ListTile(
              title: Text(I18n.of(context).postCategoriesCurated),
              onTap: () => Navigator.of(context).pop(ExploreCategory.curated()),
            ),
            ListTile(
              title: Text(I18n.of(context).postCategoriesMostViewed),
              onTap: () =>
                  Navigator.of(context).pop(ExploreCategory.mostViewed()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
    final refreshController =
        useState(RefreshController(initialRefresh: false));

    final selectedDate = useProvider(_dateProvider);
    final selectedTimeScale = useProvider(_timeScaleProvider);
    final selectedCategory = useProvider(_categoryProvider);
    final posts = useProvider(_curatedPostProvider);
    final lastViewedPostIndex = useProvider(_lastViewedPostIndexProvider);
    final postsState = useProvider(_postsStateProvider);

    final scrollController = useState(AutoScrollController());
    useEffect(() {
      return () => scrollController.dispose;
    }, []);

    useEffect(() {
      scrollController.value.scrollToIndex(lastViewedPostIndex);
      return () => null;
    }, [lastViewedPostIndex]);

    return ProviderListener<ListItemStatus<Post>>(
      provider: _postsState,
      onChange: (context, state) {
        state.maybeWhen(
          fetched: () {
            refreshController.value.loadComplete();
            refreshController.value.refreshCompleted();
          },
          error: () => Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Something went wrong"))),
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullDown: true,
        enablePullUp: true,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => context.read(exploreStateNotifierProvider).refresh(),
        onLoading: () =>
            context.read(exploreStateNotifierProvider).getMorePosts(),
        child: CustomScrollView(
          controller: scrollController.value,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Column(
                    children: [
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_left),
                            onPressed: () => context
                                .read(exploreStateNotifierProvider)
                                .reverseOneTimeUnit(),
                          ),
                          FlatButton(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            onPressed: () => DatePicker.showDatePicker(
                              context,
                              theme: DatePickerTheme(),
                              onConfirm: (time) {
                                context
                                    .read(exploreStateNotifierProvider)
                                    .updateDate(time);
                              },
                              currentTime: DateTime.now(),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                    "${DateFormat('MMM d, yyyy').format(selectedDate)}"),
                                Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () => context
                                .read(exploreStateNotifierProvider)
                                .forwardOneTimeUnit(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FlatButton(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            onPressed: () async {
                              final category =
                                  await showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context, controller) =>
                                              _buildModalCategoryPicker(
                                                  context)) ??
                                      selectedCategory;

                              context
                                  .read(exploreStateNotifierProvider)
                                  .changeCategory(category);
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                    "${selectedCategory.toString().split('.').last.replaceAll('()', '').toUpperCase()}"),
                                Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                          selectedCategory.maybeWhen(
                            mostViewed: () => Center(),
                            orElse: () => FlatButton(
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              onPressed: () async {
                                final timeScale =
                                    await showMaterialModalBottomSheet(
                                            context: context,
                                            builder: (context, controller) =>
                                                _buildModalTimeScalePicker(
                                                    context)) ??
                                        selectedTimeScale;

                                context
                                    .read(exploreStateNotifierProvider)
                                    .updateTimeScale(timeScale);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                      "${selectedTimeScale.toString().split('.').last.toUpperCase()}"),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            postsState.maybeWhen(
              refreshing: () => SliverPostGridPlaceHolder(
                  scrollController: scrollController.value),
              orElse: () => SliverPostGrid(
                onTap: (post, index) {
                  context.read(exploreStateNotifierProvider).viewPost(post);
                  AppRouter.router.navigateTo(
                    context,
                    "/posts",
                    routeSettings: RouteSettings(arguments: [
                      post,
                      "${gridKey.toString()}_${post.id}",
                      index,
                      posts,
                      () => context
                          .read(exploreStateNotifierProvider)
                          .stopViewing(),
                      (index) {
                        context
                            .read(exploreStateNotifierProvider)
                            .viewPost(posts[index]);

                        if (index > posts.length * 0.8) {
                          context
                              .read(exploreStateNotifierProvider)
                              .getMorePosts();
                        }
                      }
                    ]),
                  );
                },
                key: gridKey.value,
                posts: posts,
                scrollController: scrollController.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
