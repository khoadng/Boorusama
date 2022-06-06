// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/curated_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/most_viewed_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/popular_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/recommended/recommended_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/carousel_placeholder.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';

enum ExploreCategory {
  popular,
  curated,
  mostViewed,
}

extension ExploreCategoryX on ExploreCategory {
  String getName() {
    return "${this.toString().split('.').last.replaceAll('()', '')}";
  }
}

Future<List<Post>> categoryToAwaitablePosts(
  ExploreCategory category,
  IPostRepository postRepository,
  DateTime date,
  int page,
  TimeScale scale,
) {
  switch (category) {
    case ExploreCategory.popular:
      return postRepository.getPopularPosts(date, page, scale);
    case ExploreCategory.curated:
      return postRepository.getCuratedPosts(date, page, scale);
    default:
      return postRepository.getMostViewedPosts(date);
  }
}

class ExplorePage extends HookWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildExploreSection(ExploreCategory category) {
      final title = Text(
        "${category.getName().sentenceCase}",
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.w700),
      );

      if (category == ExploreCategory.popular) {
        return BlocBuilder<PopularCubit, AsyncLoadState<List<Post>>>(
          builder: (context, state) => _ExploreSection(
            title: title,
            posts: state,
            onViewMoreTap: () => showBarModalBottomSheet(
              context: context,
              builder: (context) {
                return _ExploreItemPage(
                  title: title,
                  category: category,
                );
              },
            ),
          ),
        );
      } else if (category == ExploreCategory.curated) {
        return BlocBuilder<CuratedCubit, AsyncLoadState<List<Post>>>(
          builder: (context, state) => _ExploreSection(
            title: title,
            posts: state,
            onViewMoreTap: () => showBarModalBottomSheet(
              context: context,
              builder: (context) {
                return _ExploreItemPage(
                  title: title,
                  category: category,
                );
              },
            ),
          ),
        );
      } else {
        return BlocBuilder<MostViewedCubit, AsyncLoadState<List<Post>>>(
          builder: (context, state) => _ExploreSection(
            title: title,
            posts: state,
            onViewMoreTap: () => showBarModalBottomSheet(
              context: context,
              builder: (context) {
                return _ExploreItemPage(
                  title: title,
                  category: category,
                );
              },
            ),
          ),
        );
      }
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
        child: _buildExploreSection(ExploreCategory.popular),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.curated),
      ),
      SliverToBoxAdapter(
        child: _buildExploreSection(ExploreCategory.mostViewed),
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
    Key? key,
    this.title,
    required this.category,
  }) : super(key: key);

  final Widget? title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState(DateTime.now());
    final selectedTimeScale = useState(TimeScale.day);
    final posts = useState(<Post>[]);
    final hasNoData = useState(false);

    final isMounted = useIsMounted();

    final infiniteListController = useState(
      InfiniteLoadListController<Post>(
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
                  orElse: () => Post.empty(),
                );
                return p.id == post.id;
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
        refreshBuilder: (page) => categoryToAwaitablePosts(
          category,
          RepositoryProvider.of<IPostRepository>(context),
          selectedDate.value,
          page,
          selectedTimeScale.value,
        ),
        loadMoreBuilder: (page) => categoryToAwaitablePosts(
          category,
          RepositoryProvider.of<IPostRepository>(context),
          selectedDate.value,
          page,
          selectedTimeScale.value,
        ),
      ),
    );

    final isRefreshing = useRefreshingState(infiniteListController.value);
    useAutoRefresh(infiniteListController.value,
        [selectedTimeScale.value, selectedDate.value]);

    Widget _buildHeader() {
      return _ExploreListItemHeader(
        selectedCategory: category,
        onDateChanged: (value) => selectedDate.value = value,
        onTimeScaleChanged: (value) => selectedTimeScale.value = value,
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
    Key? key,
    required this.selectedCategory,
    required this.onDateChanged,
    required this.onTimeScaleChanged,
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
              title: Text('dateRange.day'.tr()),
              onTap: () => Navigator.of(context).pop(TimeScale.day),
            ),
            ListTile(
              title: Text('dateRange.week'.tr()),
              onTap: () => Navigator.of(context).pop(TimeScale.week),
            ),
            ListTile(
              title: Text('dateRange.month'.tr()),
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
                primary: Theme.of(context).textTheme.headline6!.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () => DatePicker.showDatePicker(
                context,
                theme: DatePickerTheme(),
                onConfirm: (time) {
                  selectedDate.value = time;
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
            selectedCategory == ExploreCategory.mostViewed
                ? Center()
                : TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      primary: Theme.of(context).textTheme.headline6!.color,
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
                  )
          ],
        ),
      ],
    );
  }
}

class _ExploreSection extends StatelessWidget {
  _ExploreSection({
    Key? key,
    required this.title,
    required this.posts,
    required this.onViewMoreTap,
  }) : super(key: key);

  final AsyncLoadState<List<Post>> posts;
  final Widget title;
  final VoidCallback onViewMoreTap;

  Widget _buildCarousel(AsyncLoadState<List<Post>> data) {
    if (data.status == LoadStatus.success) {
      final posts = data.data!;
      if (posts.isEmpty) return CarouselPlaceholder();
      return CarouselSlider.builder(
        itemCount: posts.length,
        itemBuilder: (context, index, realIndex) {
          final post = posts[index];

          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              SlideInRoute(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => IsPostFavoritedCubit(
                        accountRepository:
                            RepositoryProvider.of<IAccountRepository>(context),
                        favoritePostRepository:
                            RepositoryProvider.of<IFavoritePostRepository>(
                                context),
                      ),
                    ),
                    BlocProvider(
                        create: (context) => RecommendedArtistPostCubit(
                            postRepository:
                                RepositoryProvider.of<IPostRepository>(
                                    context))),
                    BlocProvider(
                        create: (context) => RecommendedCharacterPostCubit(
                            postRepository:
                                RepositoryProvider.of<IPostRepository>(
                                    context))),
                    BlocProvider.value(
                        value: BlocProvider.of<AuthenticationCubit>(context)),
                    BlocProvider.value(
                        value: BlocProvider.of<ApiEndpointCubit>(context)),
                  ],
                  child: RepositoryProvider.value(
                    value: RepositoryProvider.of<ITagRepository>(context),
                    child: PostDetailPage(
                      post: post,
                      intitialIndex: index,
                      posts: posts,
                      onExit: (currentIndex) {},
                      onPostChanged: (index) {},
                    ),
                  ),
                ),
              ),
            ),
            child: Stack(
              children: [
                PostImage(
                  imageUrl: post.isAnimated
                      ? post.previewImageUri.toString()
                      : post.normalImageUri.toString(),
                  placeholderUrl: post.previewImageUri.toString(),
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
                          .headline2!
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
      );
    } else if (data.status == LoadStatus.failure) {
      return Center(
        child: Text("Something went wrong"),
      );
    } else {
      return CarouselPlaceholder();
    }
  }

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
        _buildCarousel(posts),
      ],
    );
  }
}
