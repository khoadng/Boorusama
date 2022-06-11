// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/home/explore/explore_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_curated_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_most_viewed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_popular_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class ExploreDetailPage extends StatefulWidget {
  const ExploreDetailPage({
    Key? key,
    this.title,
    required this.category,
  }) : super(key: key);

  final Widget? title;
  final ExploreCategory category;

  @override
  State<ExploreDetailPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreDetailPage> {
  final RefreshController _refreshController = RefreshController();
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        automaticallyImplyLeading: false,
        title: widget.title,
      ),
      body: BlocConsumer<ExploreDetailBloc, ExploreDetailState>(
        listener: (context, state) => _refreshController.requestRefresh(),
        builder: (context, state) {
          return Column(
            children: [
              _ExploreListItemHeader(
                scale: state.scale,
                date: state.date,
                selectedCategory: widget.category,
                onDateChanged: (date) => context
                    .read<ExploreDetailBloc>()
                    .add(ExploreDetailDateChanged(date)),
                onTimeScaleChanged: (scale) => context
                    .read<ExploreDetailBloc>()
                    .add(ExploreDetailTimeScaleChanged(scale)),
              ),
              Expanded(
                child: mapCategoryToPostList(
                    widget.category, state, _refreshController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget mapCategoryToPostList(
    ExploreCategory category,
    ExploreDetailState state,
    RefreshController refreshController,
  ) {
    if (category == ExploreCategory.popular) {
      return BlocProvider(
        create: (context) =>
            PostPopularBloc(postRepository: context.read<IPostRepository>())
              ..add(
                PostPopularRefreshed(
                  date: state.date,
                  scale: state.scale,
                ),
              ),
        child: BlocBuilder<PostPopularBloc, PostPopularState>(
          builder: (context, ppstate) => InfiniteLoadListForExplorePost(
            hasMore: ppstate.hasMore,
            scrollController: _scrollController,
            controller: refreshController,
            date: state.date,
            scale: state.scale,
            status: ppstate.status,
            posts: ppstate.posts,
            onLoadMore: (date, scale) => context
                .read<PostPopularBloc>()
                .add(PostPopularFetched(date: date, scale: scale)),
            onRefresh: (date, scale) => context
                .read<PostPopularBloc>()
                .add(PostPopularRefreshed(date: date, scale: scale)),
          ),
        ),
      );
    } else if (category == ExploreCategory.curated) {
      return BlocProvider(
        create: (context) =>
            PostCuratedBloc(postRepository: context.read<IPostRepository>())
              ..add(
                PostCuratedRefreshed(
                  date: state.date,
                  scale: state.scale,
                ),
              ),
        child: BlocBuilder<PostCuratedBloc, PostCuratedState>(
          builder: (context, ppstate) => InfiniteLoadListForExplorePost(
            hasMore: ppstate.hasMore,
            scrollController: _scrollController,
            controller: refreshController,
            date: state.date,
            scale: state.scale,
            status: ppstate.status,
            posts: ppstate.posts,
            onLoadMore: (date, scale) => context
                .read<PostCuratedBloc>()
                .add(PostCuratedFetched(date: date, scale: scale)),
            onRefresh: (date, scale) => context
                .read<PostCuratedBloc>()
                .add(PostCuratedRefreshed(date: date, scale: scale)),
          ),
        ),
      );
    } else {
      return BlocProvider(
        create: (context) =>
            PostMostViewedBloc(postRepository: context.read<IPostRepository>())
              ..add(
                PostMostViewedRefreshed(
                  date: state.date,
                ),
              ),
        child: BlocBuilder<PostMostViewedBloc, PostMostViewedState>(
          builder: (context, ppstate) => InfiniteLoadListForExplorePost(
            hasMore: ppstate.hasMore,
            scrollController: _scrollController,
            controller: refreshController,
            date: state.date,
            scale: state.scale,
            status: ppstate.status,
            posts: ppstate.posts,
            onLoadMore: (date, scale) => context
                .read<PostMostViewedBloc>()
                .add(PostMostViewedFetched(date: date)),
            onRefresh: (date, scale) => context
                .read<PostMostViewedBloc>()
                .add(PostMostViewedRefreshed(date: date)),
          ),
        ),
      );
    }
  }
}

class InfiniteLoadListForExplorePost extends StatelessWidget {
  const InfiniteLoadListForExplorePost({
    Key? key,
    required this.date,
    required this.scale,
    required this.status,
    required this.posts,
    required this.onLoadMore,
    required this.onRefresh,
    required this.controller,
    required this.scrollController,
    required this.hasMore,
  }) : super(key: key);

  final DateTime date;
  final TimeScale scale;
  final LoadStatus status;
  final List<Post> posts;
  final void Function(DateTime date, TimeScale scale) onLoadMore;
  final void Function(DateTime date, TimeScale scale) onRefresh;
  final RefreshController controller;
  final AutoScrollController scrollController;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return InfiniteLoadList2(
      enableLoadMore: hasMore,
      scrollController: scrollController,
      refreshController: controller,
      onLoadMore: () => onLoadMore(date, scale),
      onRefresh: (controller) {
        onRefresh(date, scale);
        Future.delayed(const Duration(milliseconds: 500),
            () => controller.refreshCompleted());
      },
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            sliver: mapLoadStatusToWidget(context, status, controller),
          ),
          if (status == LoadStatus.loading)
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 20, top: 20),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget mapLoadStatusToWidget(
    BuildContext context,
    LoadStatus status,
    AutoScrollController controller,
  ) {
    if (status == LoadStatus.initial) {
      return const SliverPostGridPlaceHolder();
    } else if (status == LoadStatus.success) {
      if (posts.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(child: Text("No data")),
        );
      }
      return SliverPostGrid(
        posts: posts,
        scrollController: controller,
        onTap: (post, index) => AppRouter.router.navigateTo(
          context,
          "/post/detail",
          routeSettings: RouteSettings(
            arguments: [
              posts,
              index,
              controller,
            ],
          ),
        ),
      );
    } else if (status == LoadStatus.loading) {
      if (posts.isEmpty) {
        return const SliverPostGridPlaceHolder();
      } else {
        return SliverPostGrid(
          posts: posts,
          scrollController: controller,
          onTap: (post, index) => AppRouter.router.navigateTo(
            context,
            "/post/detail",
            routeSettings: RouteSettings(
              arguments: [
                posts,
                index,
                controller,
              ],
            ),
          ),
        );
      }
    } else {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text("Something went wrong"),
        ),
      );
    }
  }
}

class _ExploreListItemHeader extends StatelessWidget {
  const _ExploreListItemHeader({
    Key? key,
    required this.selectedCategory,
    required this.onDateChanged,
    required this.onTimeScaleChanged,
    required this.date,
    required this.scale,
  }) : super(key: key);

  final ExploreCategory selectedCategory;
  final void Function(DateTime date) onDateChanged;
  final void Function(TimeScale scale) onTimeScaleChanged;
  final DateTime date;
  final TimeScale scale;

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
    return Column(
      children: [
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () =>
                  onDateChanged(Jiffy(date).dateTime.subtractTimeScale(scale)),
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
                theme: const DatePickerTheme(),
                onConfirm: (time) => onDateChanged(time),
                currentTime: DateTime.now(),
              ),
              child: Row(
                children: <Widget>[
                  Text(DateFormat('MMM d, yyyy').format(date)),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              onPressed: () =>
                  onDateChanged(Jiffy(date).dateTime.addTimeScale(scale)),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            selectedCategory == ExploreCategory.mostViewed
                ? const Center()
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
                          scale;
                      onTimeScaleChanged(timeScale);
                    },
                    child: Row(
                      children: <Widget>[
                        Text(scale
                            .toString()
                            .split('.')
                            .last
                            .replaceAll('()', '')
                            .toUpperCase()),
                        const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  )
          ],
        ),
      ],
    );
  }
}
