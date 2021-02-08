// Flutter imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/explore/explore_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/generated/i18n.dart';

final _popularPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final timeScale = ref.watch(_timeScaleProvider);
  final date = ref.watch(_dateProvider);
  final page = ref.watch(_pageProvider);

  final repo = ref.watch(postProvider);
  final dtos =
      await repo.getPopularPosts(date.state, page.state, timeScale.state);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts;
});

final _popularPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  final dtos = await repo.getPopularPosts(DateTime.now(), 1, TimeScale.day);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts.take(20).toList();
});

final _curatedPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final timeScale = ref.watch(_timeScaleProvider);
  final date = ref.watch(_dateProvider);
  final page = ref.watch(_pageProvider);

  final repo = ref.watch(postProvider);
  final dtos =
      await repo.getCuratedPosts(date.state, page.state, timeScale.state);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts;
});

final _curatedPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  final dtos = await repo.getCuratedPosts(DateTime.now(), 1, TimeScale.day);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts.take(20).toList();
});

final _mostViewedPostProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final date = ref.watch(_dateProvider);
  final repo = ref.watch(postProvider);
  final dtos = await repo.getMostViewedPosts(date.state);
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts;
});

final _mostViewedPostSneakPeakProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  final dtos = await repo.getMostViewedPosts(DateTime.now());
  final posts = dtos.map((dto) => dto.toEntity()).toList();

  return posts.take(20).toList();
});

final _timeScaleProvider = StateProvider.autoDispose<TimeScale>((ref) {
  return TimeScale.day;
});

final _dateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final _pageProvider = StateProvider<int>((ref) {
  return 1;
});

class ExplorePage extends HookWidget {
  const ExplorePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildExploreSection(ExploreCategory category) {
      return _ExploreSection(
        title: Text("${category.getName().toUpperCase()}"),
        posts: category.when(
          popular: () => useProvider(_popularPostSneakPeakProvider),
          curated: () => useProvider(_curatedPostSneakPeakProvider),
          mostViewed: () => useProvider(_mostViewedPostSneakPeakProvider),
        ),
        onViewMoreTap: () => showBarModalBottomSheet(
          context: context,
          builder: (context, controller) {
            return _ExploreItemPage(
              title: Text("${category.getName().toUpperCase()}"),
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

    final scrollController = useState(AutoScrollController());
    useEffect(() {
      return () => scrollController.dispose;
    }, []);

    useEffect(() {
      postsAtPage.whenData((data) {
        posts.value = [...posts.value, ...data];
      });

      return null;
    }, [postsAtPage]);

    useValueChanged(posts.value, (_, __) {
      if (posts.value.isNotEmpty) {
        isRefreshing.value = false;
        refreshController.value.refreshCompleted();
      }
    });

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
        body: isRefreshing.value
            ? Column(
                children: [
                  _ExploreListItemHeader(
                    selectedCategory: category,
                    onDateChanged: (value) => selectedDate.state = value,
                    onTimeScaleChanged: (value) =>
                        selectedTimeScale.state = value,
                  ),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              )
            : InfiniteLoadList(
                header: SliverToBoxAdapter(
                  child: _ExploreListItemHeader(
                    selectedCategory: category,
                    onDateChanged: (value) => selectedDate.state = value,
                    onTimeScaleChanged: (value) =>
                        selectedTimeScale.state = value,
                  ),
                ),
                scrollController: scrollController.value,
                gridKey: gridKey.value,
                posts: posts.value,
                refreshController: refreshController.value,
                onItemChanged: (index) => loadMoreIfNeeded(index),
                onRefresh: () => refresh(),
                onLoadMore: () => loadMore()));
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
  const _ExploreSection({
    Key key,
    @required this.title,
    @required this.posts,
    @required this.onViewMoreTap,
  }) : super(key: key);

  final AsyncValue<List<Post>> posts;
  final Widget title;
  final VoidCallback onViewMoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            title: title,
            trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () => onViewMoreTap())),
        posts.when(
          data: (posts) => CarouselSlider.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostImage(
                imageUrl: post.isAnimated
                    ? post.previewImageUri.toString()
                    : post.normalImageUri.toString(),
                placeholderUrl: post.previewImageUri.toString(),
              );
            },
            options: CarouselOptions(
              aspectRatio: 1.5,
              viewportFraction: 0.5,
              initialPage: 0,
              autoPlay: true,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              scrollDirection: Axis.horizontal,
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text("Something went wrong"),
          ),
        ),
      ],
    );
  }
}
