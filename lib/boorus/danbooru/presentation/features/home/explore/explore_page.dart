// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:recase/recase.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/carousel_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/top_shadow_gradient_overlay.dart';
import 'package:boorusama/generated/i18n.dart';

part 'explore_page.freezed.dart';

@freezed
abstract class ExploreCategory with _$ExploreCategory {
  const factory ExploreCategory.popular() = _Popular;
  const factory ExploreCategory.curated() = _Curated;
  const factory ExploreCategory.mostViewed() = _MostViewed;
}

extension ExploreCategoryX on ExploreCategory {
  String getName() {
    return "${this.toString().split('.').last.replaceAll('()', '')}";
  }
}

final _popularPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final timeScale = ref.watch(_timeScaleProvider);
  final date = ref.watch(_dateProvider);
  final page = ref.watch(_pageProvider);

  final repo = ref.watch(postProvider);
  final posts =
      await repo.getPopularPosts(date.state, page.state, timeScale.state);

  return posts;
});

final _popularPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  var posts = await repo.getPopularPosts(DateTime.now(), 1, TimeScale.day);
  if (posts.isEmpty) {
    posts = await repo.getPopularPosts(
        DateTime.now().subtract(Duration(days: 1)), 1, TimeScale.day);
  }

  return posts.take(20).toList();
});

final _curatedPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final timeScale = ref.watch(_timeScaleProvider);
  final date = ref.watch(_dateProvider);
  final page = ref.watch(_pageProvider);

  final repo = ref.watch(postProvider);
  final posts =
      await repo.getCuratedPosts(date.state, page.state, timeScale.state);

  return posts;
});

final _curatedPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  var posts = await repo.getCuratedPosts(DateTime.now(), 1, TimeScale.day);

  if (posts.isEmpty) {
    posts = await repo.getCuratedPosts(
        DateTime.now().subtract(Duration(days: 1)), 1, TimeScale.day);
  }

  return posts.take(20).toList();
});

final _mostViewedPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final date = ref.watch(_dateProvider);
  final repo = ref.watch(postProvider);
  final posts = await repo.getMostViewedPosts(date.state);

  return posts;
});

final _mostViewedPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  var posts = await repo.getMostViewedPosts(DateTime.now());

  if (posts.isEmpty) {
    posts = await repo
        .getMostViewedPosts(DateTime.now().subtract(Duration(days: 1)));
  }

  return posts.take(20).toList();
});

final _timeScaleProvider = StateProvider.autoDispose<TimeScale>((ref) {
  return TimeScale.day;
});

final _dateProvider = StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});

final _pageProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

class ExplorePage extends HookWidget {
  const ExplorePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildExploreSection(ExploreCategory category) {
      final title = Text(
        "${category.getName().sentenceCase}",
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(fontWeight: FontWeight.w700),
      );
      return _ExploreSection(
        title: title,
        posts: category.when(
          popular: () => useProvider(_popularPostSneakPeakProvider),
          curated: () => useProvider(_curatedPostSneakPeakProvider),
          mostViewed: () => useProvider(_mostViewedPostSneakPeakProvider),
        ),
        onViewMoreTap: () => showBarModalBottomSheet(
          context: context,
          builder: (context, controller) {
            return _ExploreItemPage(
              title: title,
              provider: category.when(
                popular: () => _popularPostProvider,
                curated: () => _curatedPostProvider,
                mostViewed: () => _mostViewedPostProvider,
              ),
              category: category,
            );
          },
        ),
      );
    }

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.popular()),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.curated()),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.mostViewed()),
      ),
    ]);
  }
}

class _ExploreItemPage extends HookWidget {
  const _ExploreItemPage({
    Key key,
    this.title,
    @required this.provider,
    @required this.category,
  }) : super(key: key);

  final AutoDisposeFutureProvider<List<Post>> provider;
  final Widget title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    final refreshController = useState(RefreshController());
    final selectedDate = useProvider(_dateProvider);
    final selectedTimeScale = useProvider(_timeScaleProvider);
    final posts = useState(<Post>[]);
    final page = useProvider(_pageProvider);
    final postsAtPage = useProvider(provider);
    final gridKey = useState(GlobalKey());

    final isRefreshing = useState(true);
    final hasNoData = useState(false);

    final scrollController = useState(AutoScrollController());

    void loadMoreIfNeeded(int index) {
      if (index > posts.value.length * 0.8) {
        page.state = page.state + 1;
      }
    }

    void refresh() {
      isRefreshing.value = true;
      page.state = 1;
    }

    void loadMore() {
      page.state = page.state + 1;
    }

    useEffect(() {
      return () => scrollController.dispose;
    }, []);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refresh();
      });

      return null;
    }, [selectedTimeScale.state, selectedDate.state]);

    useEffect(() {
      postsAtPage.whenData((data) {
        if (isRefreshing.value) {
          isRefreshing.value = false;
          posts.value = data;
        } else {
          // in Loading mode
          refreshController.value.loadComplete();
          posts.value = [...posts.value, ...data];
        }

        if (data.isEmpty) {
          refreshController.value.loadNoData();
        }

        hasNoData.value = data.isEmpty && posts.value.isEmpty;
      });

      return null;
    }, [postsAtPage]);

    Widget _buildHeader() {
      return _ExploreListItemHeader(
        selectedCategory: category,
        onDateChanged: (value) => selectedDate.state = value,
        onTimeScaleChanged: (value) => selectedTimeScale.state = value,
      );
    }

    Widget _buildPageContent() {
      if (isRefreshing.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        if (hasNoData.value) {
          return Center(
            child: Text("No data"),
          );
        } else {
          return InfiniteLoadList(
              // header: SliverToBoxAdapter(child: header),
              scrollController: scrollController.value,
              gridKey: gridKey.value,
              posts: posts.value,
              refreshController: refreshController.value,
              onItemChanged: (index) => loadMoreIfNeeded(index),
              onRefresh: () => refresh(),
              onLoadMore: () => loadMore());
        }
      }
    }

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          automaticallyImplyLeading: false,
          title: title,
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildPageContent()),
          ],
        ));
  }
}

class _ExploreListItemHeader extends HookWidget {
  const _ExploreListItemHeader({
    Key key,
    @required this.selectedCategory,
    @required this.onDateChanged,
    @required this.onTimeScaleChanged,
  }) : super(key: key);

  final ExploreCategory selectedCategory;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeScale> onTimeScaleChanged;

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

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState(DateTime.now());
    final selectedTimeScale = useState(TimeScale.day);

    return Column(
      children: [
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                DateTime previous;

                switch (selectedTimeScale.value) {
                  case TimeScale.day:
                    previous = Jiffy(selectedDate.value).subtract(days: 1);
                    break;
                  case TimeScale.week:
                    previous = Jiffy(selectedDate.value).subtract(weeks: 1);
                    break;
                  case TimeScale.month:
                    previous = Jiffy(selectedDate.value).subtract(months: 1);
                    break;
                  default:
                    previous = Jiffy(selectedDate.value).subtract(days: 1);
                    break;
                }

                selectedDate.value = previous;
                onDateChanged(previous);
              },
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
                  onDateChanged(time);
                },
                currentTime: DateTime.now(),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                      "${DateFormat('MMM d, yyyy').format(selectedDate.value)}"),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                DateTime next;

                switch (selectedTimeScale.value) {
                  case TimeScale.day:
                    next = Jiffy(selectedDate.value).add(days: 1);
                    break;
                  case TimeScale.week:
                    next = Jiffy(selectedDate.value).add(weeks: 1);
                    break;
                  case TimeScale.month:
                    next = Jiffy(selectedDate.value).add(months: 1);
                    break;
                  default:
                    next = Jiffy(selectedDate.value).add(days: 1);
                    break;
                }

                selectedDate.value = next;
                onDateChanged(next);
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selectedCategory.maybeWhen(
              mostViewed: () => Center(),
              orElse: () => FlatButton(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () async {
                  final timeScale = await showMaterialModalBottomSheet(
                          context: context,
                          builder: (context, controller) =>
                              _buildModalTimeScalePicker(context)) ??
                      selectedTimeScale.value;

                  selectedTimeScale.value = timeScale;
                  onTimeScaleChanged(timeScale);
                },
                child: Row(
                  children: <Widget>[
                    Text(
                        "${selectedTimeScale.value.toString().split('.').last.replaceAll('()', '').toUpperCase()}"),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExploreSection extends StatelessWidget {
  _ExploreSection({
    Key key,
    @required this.title,
    @required this.posts,
    @required this.onViewMoreTap,
  }) : super(key: key);

  final AsyncValue<List<Post>> posts;
  final Widget title;
  final VoidCallback onViewMoreTap;
  final GlobalKey gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: title,
          trailing: TextButton(
              onPressed: () => onViewMoreTap(),
              child:
                  Text("See more", style: Theme.of(context).textTheme.button)),
        ),
        posts.when(
          data: (posts) => posts.isNotEmpty
              ? CarouselSlider.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () => AppRouter.router.navigateTo(
                            context,
                            "/posts",
                            routeSettings: RouteSettings(arguments: [
                              post,
                              index,
                              posts,
                              () => null,
                              (index) {},
                              gridKey,
                            ]),
                          ),
                          child: PostImage(
                            imageUrl: post.isAnimated
                                ? post.previewImageUri.toString()
                                : post.normalImageUri.toString(),
                            placeholderUrl: post.previewImageUri.toString(),
                          ),
                        ),
                        TopShadowGradientOverlay(
                          colors: <Color>[
                            const Color(0xC2000000),
                            Colors.black12.withOpacity(0.0)
                          ],
                        ),
                        Align(
                            alignment: Alignment(-0.9, -1),
                            child: Text(
                              "${index + 1}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  .copyWith(color: Colors.white),
                            )),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    aspectRatio: 1.5,
                    viewportFraction: 0.5,
                    initialPage: 0,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    scrollDirection: Axis.horizontal,
                  ),
                )
              : CarouselPlaceholder(),
          loading: () => CarouselPlaceholder(),
          error: (error, stackTrace) => Center(
            child: Text("Something went wrong"),
          ),
        ),
      ],
    );
  }
}
