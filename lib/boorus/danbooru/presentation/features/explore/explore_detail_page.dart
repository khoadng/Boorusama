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
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_curated_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_most_viewed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_popular_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class ExploreDetail extends StatefulWidget {
  const ExploreDetail({
    Key? key,
    required this.title,
    required this.builder,
  }) : super(key: key);

  final Widget title;
  final Widget Function(
    BuildContext context,
    RefreshController refreshController,
    AutoScrollController scrollController,
  ) builder;

  @override
  State<ExploreDetail> createState() => _ExploreDetailState();
}

class _ExploreDetailState extends State<ExploreDetail> {
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
        title: widget.title,
      ),
      body: BlocConsumer<ExploreDetailBloc, ExploreDetailState>(
        listener: (context, state) {
          _scrollController.jumpTo(0);
          _refreshController.requestRefresh();
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: widget.builder(
                  context,
                  _refreshController,
                  _scrollController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExploreDetailPage2 extends StatelessWidget {
  const ExploreDetailPage2({
    Key? key,
    required this.title,
    required this.category,
  }) : super(key: key);

  final Widget title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreDetailBloc, ExploreDetailState>(
      builder: (context, state) {
        return ExploreDetail(
          title: title,
          builder: (context, refreshController, scrollController) {
            if (category == ExploreCategory.popular) {
              return BlocProvider(
                create: (context) => PostPopularBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostPopularRefreshed(
                      date: state.date,
                      scale: state.scale,
                    ),
                  ),
                child: BlocBuilder<PostPopularBloc, PostPopularState>(
                  builder: (context, ppstate) => InfiniteLoadListForExplorePost(
                    header: DateAndTimeScaleHeader(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      onTimeScaleChanged: (scale) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailTimeScaleChanged(scale)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
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
                create: (context) => PostCuratedBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostCuratedRefreshed(
                      date: state.date,
                      scale: state.scale,
                    ),
                  ),
                child: BlocBuilder<PostCuratedBloc, PostCuratedState>(
                  builder: (context, ppstate) => InfiniteLoadListForExplorePost(
                    header: DateAndTimeScaleHeader(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      onTimeScaleChanged: (scale) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailTimeScaleChanged(scale)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
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
                create: (context) => PostMostViewedBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostMostViewedRefreshed(
                      date: state.date,
                    ),
                  ),
                child: BlocBuilder<PostMostViewedBloc, PostMostViewedState>(
                  builder: (context, ppstate) => InfiniteLoadListForExplorePost(
                    header: DateTimeSelector(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
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
          },
        );
      },
    );
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
    required this.header,
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
  final Widget header;

  @override
  Widget build(BuildContext context) {
    return InfiniteLoadList(
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
        slivers: [
          SliverToBoxAdapter(
            child: header,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
          child: Center(child: Text('No data')),
        );
      }
      return SliverPostGrid(
        posts: posts,
        scrollController: controller,
        onTap: (post, index) => AppRouter.router.navigateTo(
          context,
          '/post/detail',
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
            '/post/detail',
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
          child: Text('Something went wrong'),
        ),
      );
    }
  }
}

class DateAndTimeScaleHeader extends StatelessWidget {
  const DateAndTimeScaleHeader({
    Key? key,
    required this.onDateChanged,
    required this.onTimeScaleChanged,
    required this.date,
    required this.scale,
  }) : super(key: key);

  final void Function(DateTime date) onDateChanged;
  final void Function(TimeScale scale) onTimeScaleChanged;
  final DateTime date;
  final TimeScale scale;

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
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => DatePicker.showDatePicker(
                context,
                theme: const DatePickerTheme(),
                onConfirm: onDateChanged,
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
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                primary: Theme.of(context).textTheme.headline6!.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () async {
                final timeScale = await showMaterialModalBottomSheet(
                        context: context,
                        builder: _buildModalTimeScalePicker) ??
                    scale;
                onTimeScaleChanged(timeScale);
              },
              child: Row(
                children: [
                  Text(_timeScaleToString(scale).tr().toUpperCase()),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

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
}

class DateTimeSelector extends StatelessWidget {
  const DateTimeSelector({
    Key? key,
    required this.onDateChanged,
    required this.date,
    required this.scale,
  }) : super(key: key);

  final void Function(DateTime date) onDateChanged;
  final DateTime date;
  final TimeScale scale;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
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
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () => DatePicker.showDatePicker(
            context,
            theme: const DatePickerTheme(),
            onConfirm: onDateChanged,
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
    );
  }
}

String _timeScaleToString(TimeScale scale) {
  switch (scale) {
    case TimeScale.month:
      return 'dateRange.month';
    case TimeScale.week:
      return 'dateRange.week';
    default:
      return 'dateRange.day';
  }
}
