// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/carousel_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
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

// final _popularSearchProvider =
//     FutureProvider.autoDispose<List<Search>>((ref) async {
//   final repo = ref.watch(popularSearchProvider);

//   var searches = await repo.getSearchByDate(DateTime.now());
//   if (searches.isEmpty) {
//     searches =
//         await repo.getSearchByDate(DateTime.now().subtract(Duration(days: 1)));
//   }

//   ref.maintainState = true;

//   return searches;
// });

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
          builder: (context) {
            return _ExploreItemPage(
              title: title,
              category: category,
            );
          },
        ),
      );
    }

    return CustomScrollView(slivers: [
      //TODO: doesn't looks good without some images slapped on it
      // popularSearch.maybeWhen(
      //   data: (searches) => SliverPadding(
      //     padding: EdgeInsets.all(10.0),
      //     sliver: SliverGrid.count(
      //       mainAxisSpacing: 8,
      //       crossAxisSpacing: 8,
      //       childAspectRatio: 4.5,
      //       crossAxisCount: 2,
      //       children: searches
      //           .take(10)
      //           .map(
      //             (search) => Container(
      //                 decoration: BoxDecoration(
      //                   color: Theme.of(context).accentColor,
      //                   borderRadius: BorderRadius.circular(8.0),
      //                 ),
      //                 child: Center(child: Text("#${search.keyword.pretty}"))),
      //           )
      //           .toList(),
      //     ),
      //   ),
      //   orElse: () => SliverToBoxAdapter(
      //     child: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   ),
      // ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.popular()),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.curated()),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.mostViewed()),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: kBottomNavigationBarHeight,
        ),
      ),
    ]);
  }
}

class _ExploreItemPage extends HookWidget {
  const _ExploreItemPage({
    Key key,
    this.title,
    @required this.category,
  }) : super(key: key);

  final Widget title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    final selectedDate = useProvider(_dateProvider);
    final selectedTimeScale = useProvider(_timeScaleProvider);
    final posts = useState(<Post>[]);
    final hasNoData = useState(false);

    final isMounted = useIsMounted();

    final infiniteListController = useState(InfiniteLoadListController<Post>(
      onData: (data) {
        if (isMounted()) {
          posts.value = [...data];
          hasNoData.value = data.isEmpty;
        }
      },
      onMoreData: (data, page) {
        if (page > 1) {
          // Dedupe
          data
            ..removeWhere((post) {
              final p = posts.value.firstWhere(
                (sPost) => sPost.id == post.id,
                orElse: () => null,
              );
              return p?.id == post.id;
            });
        }
        posts.value = [...posts.value, ...data];
      },
      onError: (message) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          content: Text(message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      refreshBuilder: (page) => category.when(
        curated: () => context
            .read(postProvider)
            .getCuratedPosts(selectedDate.state, page, selectedTimeScale.state),
        popular: () => context
            .read(postProvider)
            .getPopularPosts(selectedDate.state, page, selectedTimeScale.state),
        mostViewed: () =>
            context.read(postProvider).getMostViewedPosts(selectedDate.state),
      ),
      loadMoreBuilder: (page) => category.when(
        curated: () => context
            .read(postProvider)
            .getCuratedPosts(selectedDate.state, page, selectedTimeScale.state),
        popular: () => context
            .read(postProvider)
            .getPopularPosts(selectedDate.state, page, selectedTimeScale.state),
        mostViewed: () =>
            context.read(postProvider).getMostViewedPosts(selectedDate.state),
      ),
    ));

    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value,
        [selectedTimeScale.state, selectedDate.state]);

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
            controller: infiniteListController.value,
            // header: SliverToBoxAdapter(child: header),
            posts: posts.value,
          );
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
                final jiffy = Jiffy(selectedDate.value);
                switch (selectedTimeScale.value) {
                  case TimeScale.day:
                    jiffy..subtract(days: 1);
                    break;
                  case TimeScale.week:
                    jiffy..subtract(weeks: 1);
                    break;
                  case TimeScale.month:
                    jiffy..subtract(months: 1);
                    break;
                  default:
                    jiffy..subtract(days: 1);
                    break;
                }

                selectedDate.value = jiffy.dateTime;
                onDateChanged(selectedDate.value);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                primary: Theme.of(context).textTheme.headline6.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
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
                final jiffy = Jiffy(selectedDate.value);

                switch (selectedTimeScale.value) {
                  case TimeScale.day:
                    jiffy..add(days: 1);
                    break;
                  case TimeScale.week:
                    jiffy..add(weeks: 1);
                    break;
                  case TimeScale.month:
                    jiffy..add(months: 1);
                    break;
                  default:
                    jiffy..add(days: 1);
                    break;
                }

                selectedDate.value = jiffy.dateTime;
                onDateChanged(selectedDate.value);
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selectedCategory.maybeWhen(
              mostViewed: () => Center(),
              orElse: () => TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  primary: Theme.of(context).textTheme.headline6.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                onPressed: () async {
                  final timeScale = await showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) =>
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
                  itemBuilder: (context, index, realIndex) {
                    final post = posts[index];
                    return OpenContainer(
                      closedColor: Colors.transparent,
                      openBuilder: (context, action) => PostDetailPage(
                        post: post,
                        intitialIndex: index,
                        posts: posts,
                        onExit: (currentIndex) {},
                        onPostChanged: (index) {},
                      ),
                      closedBuilder: (context, action) => Stack(
                        children: [
                          GestureDetector(
                            child: PostImage(
                              imageUrl: post.isAnimated
                                  ? post.previewImageUri.toString()
                                  : post.normalImageUri.toString(),
                              placeholderUrl: post.previewImageUri.toString(),
                            ),
                          ),
                          ShadowGradientOverlay(
                            alignment: Alignment.bottomCenter,
                            colors: <Color>[
                              const Color(0xC2000000),
                              Colors.black12.withOpacity(0.0)
                            ],
                          ),
                          Align(
                              alignment: Alignment(-0.9, 1),
                              child: Text(
                                "${index + 1}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    .copyWith(color: Colors.white),
                              )),
                        ],
                      ),
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
