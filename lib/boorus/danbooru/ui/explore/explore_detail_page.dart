// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/posts/danbooru_infinite_post_list2.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'datetime_selector.dart';
import 'time_scale_toggle_switch.dart';

class ExploreDetailPage extends StatefulWidget {
  const ExploreDetailPage({
    super.key,
    required this.title,
    required this.category,
  });

  final Widget title;
  final ExploreCategory category;

  @override
  State<ExploreDetailPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreDetailPage>
    with DanbooruExploreCubitMixin {
  late final controller = PostGridController<DanbooruPost>(
      fetcher: fetchPost, refresher: refreshPost);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExploreDetailBloc>().state;

    return BlocListener<ExploreDetailBloc, ExploreDetailState>(
      listener: (context, state) => controller.refresh(),
      child: _ExploreDetail(
        // title: title,
        builder: (context, scrollController) {
          return Column(
            children: [
              Expanded(
                child: DanbooruInfinitePostList2(
                  controller: controller,
                  scrollController: scrollController,
                  onLoadMore: () {},
                  sliverHeaderBuilder: (context) => [
                    SliverAppBar(
                      title: widget.title,
                      floating: true,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                    ),
                    ...categoryToListHeader(
                      context,
                      widget.category,
                      state.date,
                      state.scale,
                    ).map((header) => SliverToBoxAdapter(child: header)),
                  ],
                ),
              ),
              if (widget.category != ExploreCategory.hot)
                Container(
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  child: DateTimeSelector(
                    onDateChanged: (date) => context
                        .read<ExploreDetailBloc>()
                        .add(ExploreDetailDateChanged(date)),
                    date: state.date,
                    scale: state.scale,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExploreDetail extends StatefulWidget {
  const _ExploreDetail({
    // required this.title,
    required this.builder,
  });

  // final Widget title;
  final Widget Function(
    BuildContext context,
    AutoScrollController scrollController,
  ) builder;

  @override
  State<_ExploreDetail> createState() => _ExploreDetailState();
}

class _ExploreDetailState extends State<_ExploreDetail> {
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExploreDetailBloc, ExploreDetailState>(
      listener: (context, state) {
        _scrollController.jumpTo(0);
      },
      child: widget.builder(
        context,
        _scrollController,
      ),
    );
  }
}

List<Widget> categoryToListHeader(
  BuildContext context,
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
) {
  switch (category) {
    case ExploreCategory.popular:
      return [
        TimeScaleToggleSwitch(
          onToggle: (scale) => {
            context
                .read<ExploreDetailBloc>()
                .add(ExploreDetailTimeScaleChanged(scale)),
          },
        ),
        const SizedBox(height: 20),
      ];
    case ExploreCategory.mostViewed:
    case ExploreCategory.hot:
      return [];
  }
}
