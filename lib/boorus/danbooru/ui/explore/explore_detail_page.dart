// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/posts/danbooru_infinite_post_list2.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'datetime_selector.dart';
import 'time_scale_toggle_switch.dart';

class ExploreDetailPage extends StatefulWidget {
  const ExploreDetailPage({
    super.key,
    required this.title,
    required this.category,
    required this.controller,
  });

  final Widget title;
  final ExploreCategory category;
  final PostGridController<DanbooruPost> controller;

  @override
  State<ExploreDetailPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreDetailPage>
    with DanbooruExploreCubitMixin {
  final AutoScrollController _scrollController = AutoScrollController();

  late final controller = widget.controller;

  // FIXME: doesn't used yet
  late final exploreDetails = ValueNotifier(
    ExploreDetailsData(
      scale: TimeScale.day,
      date: DateTime.now(),
      category: widget.category,
    ),
  );

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  List<Widget> categoryToListHeader(
    ExploreDetailsData exploreDetailsData,
  ) {
    switch (exploreDetailsData.category) {
      case ExploreCategory.popular:
        return [
          TimeScaleToggleSwitch(
            onToggle: (scale) => {
              exploreDetails.value = exploreDetails.value.copyWith(
                scale: scale,
              )
            },
          ),
          const SizedBox(height: 20),
        ];
      case ExploreCategory.mostViewed:
      case ExploreCategory.hot:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ExploreDetailsData>(
      valueListenable: exploreDetails,
      builder: (_, data, __) => Column(
        children: [
          Expanded(
            child: DanbooruInfinitePostList2(
              controller: controller,
              scrollController: _scrollController,
              onLoadMore: () {},
              sliverHeaderBuilder: (context) => [
                SliverAppBar(
                  title: widget.title,
                  floating: true,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                ...categoryToListHeader(data)
                    .map((header) => SliverToBoxAdapter(child: header)),
              ],
            ),
          ),
          if (widget.category != ExploreCategory.hot)
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) => {
                  exploreDetails.value = exploreDetails.value.copyWith(
                    date: date,
                  )
                },
                date: data.date,
                scale: data.scale,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}
