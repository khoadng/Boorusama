import 'package:boorusama/application/home/popular/popular_state_notifier.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../sliver_post_grid_placeholder.dart';

final popularStateNotifierProvider =
    StateNotifierProvider<PopularStateNotifier>(
        (ref) => PopularStateNotifier(ref));

class PopularView extends HookWidget {
  const PopularView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
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
              if (posts.isEmpty) {
                refreshController.value.loadNoData();
              } else {
                refreshController.value.loadComplete();
                refreshController.value.refreshCompleted();
                currentPosts.value.addAll(posts);
              }
            },
            orElse: () {});
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () => DatePicker.showDatePicker(
              context,
              theme: DatePickerTheme(),
              onConfirm: (time) {
                selectedDate.value = time;
                context
                    .read(popularStateNotifierProvider)
                    .getPosts(selectedDate.value, 1, selectedTimeScale.value);
              },
              currentTime: DateTime.now(),
            ),
            child: Icon(Icons.calendar_today),
          ),
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
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "${I18n.of(context).postCategoriesPopular}: ${DateFormat('MMM d, yyyy').format(selectedDate.value)}"),
                          ),
                          Row(
                            children: [
                              Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<TimeScale>(
                                      value: selectedTimeScale.value,
                                      icon: Icon(Icons.arrow_drop_down),
                                      onChanged: (value) {
                                        selectedTimeScale.value = value;
                                        context
                                            .read(popularStateNotifierProvider)
                                            .getPosts(selectedDate.value, 1,
                                                selectedTimeScale.value);
                                      },
                                      items: <DropdownMenuItem<TimeScale>>[
                                        DropdownMenuItem(
                                            value: TimeScale.day,
                                            child: Text(
                                                I18n.of(context).dateRangeDay)),
                                        DropdownMenuItem(
                                            value: TimeScale.week,
                                            child: Text(I18n.of(context)
                                                .dateRangeWeek)),
                                        DropdownMenuItem(
                                            value: TimeScale.month,
                                            child: Text(I18n.of(context)
                                                .dateRangeMonth)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                      context
                                          .read(popularStateNotifierProvider)
                                          .getPosts(selectedDate.value, 1,
                                              selectedTimeScale.value);
                                    },
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
                                      context
                                          .read(popularStateNotifierProvider)
                                          .getPosts(selectedDate.value, 1,
                                              selectedTimeScale.value);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    popularState.when(
                      initial: () => SliverPostGridPlaceHolder(),
                      loading: () => SliverPostGrid(posts: currentPosts.value),
                      fetched: (posts) => SliverPostGrid(
                        key: gridKey.value,
                        posts: currentPosts.value,
                      ),
                      error: (name, message) => SliverPostGridPlaceHolder(),
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
