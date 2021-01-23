import 'package:boorusama/boorus/danbooru/application/home/popular/popular_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../shared/sliver_post_grid_placeholder.dart';

final popularStateNotifierProvider =
    StateNotifierProvider<PopularStateNotifier>(
        (ref) => PopularStateNotifier(ref));

class PopularView extends HookWidget {
  const PopularView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
    final scrollController = useScrollController();
    final selectedDate = useState(DateTime.now());
    final selectedTimeScale = useState(TimeScale.day);
    final currentPosts = useState(<Post>[]);
    final page = useState(1);
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final popularState = useProvider(popularStateNotifierProvider.state);

    useEffect(() {
      Future.microtask(() => context
          .read(popularStateNotifierProvider)
          .refresh(selectedDate.value, selectedTimeScale.value));
      return () => {};
    }, []);

    return ProviderListener<PopularState>(
      provider: popularStateNotifierProvider.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts) {
              refreshController.value.refreshCompleted();
              if (posts.isEmpty) {
                refreshController.value.loadNoData();
              } else {
                refreshController.value.loadComplete();
                currentPosts.value.addAll(posts);
              }
            },
            orElse: () {});
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: Builder(
            // This Builder is needed to provide a BuildContext that is "inside"
            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
            // find the NestedScrollView.
            builder: (BuildContext context) {
              return SmartRefresher(
                controller: refreshController.value,
                enablePullDown: true,
                enablePullUp: true,
                header: const WaterDropMaterialHeader(),
                footer: const ClassicFooter(),
                onRefresh: () {
                  currentPosts.value.clear();
                  context
                      .read(popularStateNotifierProvider)
                      .refresh(selectedDate.value, selectedTimeScale.value);
                },
                onLoading: () {
                  page.value = page.value + 1;
                  context.read(popularStateNotifierProvider).getPosts(
                      selectedDate.value, page.value, selectedTimeScale.value);
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonBar(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_left),
                                    onPressed: () {
                                      switch (selectedTimeScale.value) {
                                        case TimeScale.day:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .subtract(days: 1);
                                          break;
                                        case TimeScale.week:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .subtract(weeks: 1);
                                          break;
                                        case TimeScale.month:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .subtract(months: 1);
                                          break;
                                        default:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .subtract(days: 1);
                                          break;
                                      }
                                      currentPosts.value.clear();
                                      context
                                          .read(popularStateNotifierProvider)
                                          .refresh(selectedDate.value,
                                              selectedTimeScale.value);
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
                                        selectedDate.value = time;
                                        context
                                            .read(popularStateNotifierProvider)
                                            .getPosts(selectedDate.value, 1,
                                                selectedTimeScale.value);
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
                                      switch (selectedTimeScale.value) {
                                        case TimeScale.day:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .add(days: 1);
                                          break;
                                        case TimeScale.week:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .add(weeks: 1);
                                          break;
                                        case TimeScale.month:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .add(months: 1);
                                          break;
                                        default:
                                          selectedDate.value =
                                              Jiffy(selectedDate.value)
                                                  .add(days: 1);
                                          break;
                                      }
                                      currentPosts.value.clear();
                                      context
                                          .read(popularStateNotifierProvider)
                                          .refresh(selectedDate.value,
                                              selectedTimeScale.value);
                                    },
                                  ),
                                ],
                              ),
                              FlatButton(
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                onPressed: () async {
                                  selectedTimeScale.value =
                                      await showMaterialModalBottomSheet(
                                            context: context,
                                            builder: (context, controller) =>
                                                Material(
                                              child: SafeArea(
                                                top: false,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ListTile(
                                                      title: Text(
                                                          I18n.of(context)
                                                              .dateRangeDay),
                                                      onTap: () => Navigator.of(
                                                              context)
                                                          .pop(TimeScale.day),
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                          I18n.of(context)
                                                              .dateRangeWeek),
                                                      onTap: () => Navigator.of(
                                                              context)
                                                          .pop(TimeScale.week),
                                                    ),
                                                    ListTile(
                                                      title: Text(
                                                          I18n.of(context)
                                                              .dateRangeMonth),
                                                      onTap: () => Navigator.of(
                                                              context)
                                                          .pop(TimeScale.month),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ) ??
                                          selectedTimeScale.value;

                                  context
                                      .read(popularStateNotifierProvider)
                                      .getPosts(selectedDate.value, 1,
                                          selectedTimeScale.value);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                        "${selectedTimeScale.value.toString().split('.').last.toUpperCase()}"),
                                    Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    popularState.when(
                      initial: () => SliverPostGridPlaceHolder(
                          scrollController: scrollController),
                      refreshing: () {
                        return SliverPostGridPlaceHolder(
                            scrollController: scrollController);
                      },
                      loading: () => SliverPostGrid(
                        posts: currentPosts.value,
                        scrollController: scrollController,
                      ),
                      fetched: (posts) => SliverPostGrid(
                        key: gridKey.value,
                        posts: currentPosts.value,
                        scrollController: scrollController,
                      ),
                      error: (name, message) => SliverPostGridPlaceHolder(
                          scrollController: scrollController),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
