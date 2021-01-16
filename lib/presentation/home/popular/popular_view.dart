import 'package:boorusama/application/home/popular/popular_state_notifier.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/presentation/home/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../sliver_post_grid_placeholder.dart';

final popularStateNotifierProvider =
    StateNotifierProvider<PopularStateNotifier>(
        (ref) => PopularStateNotifier(ref));

class PopularView extends StatefulWidget {
  PopularView({Key key}) : super(key: key);

  @override
  _PopularViewState createState() => _PopularViewState();
}

class _PopularViewState extends State<PopularView>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;
  TimeScale _currentSelectedTimeScale;
  int _currentPage = 1;
  List<Post> _posts = <Post>[];

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    _currentSelectedTimeScale = TimeScale.day;

    Future.delayed(
        Duration.zero,
        () => context
            .read(popularStateNotifierProvider)
            .refresh(_currentSelectedDate, _currentSelectedTimeScale));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderListener<PopularState>(
      provider: popularStateNotifierProvider.state,
      onChange: (context, state) => state.maybeWhen(
          fetched: (posts, page, date, scale) => setState(() {
                _currentSelectedDate = date;
                _currentSelectedTimeScale = scale;
                _refreshController
                  ..loadComplete()
                  ..refreshCompleted();
              }),
          orElse: () => null),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () => _handleTimePick(context),
            child: Icon(Icons.calendar_today),
          ),
          body: Builder(
            // This Builder is needed to provide a BuildContext that is "inside"
            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
            // find the NestedScrollView.
            builder: (BuildContext context) {
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: const WaterDropMaterialHeader(),
                footer: const ClassicFooter(),
                onRefresh: () => context
                    .read(popularStateNotifierProvider)
                    .refresh(_currentSelectedDate, _currentSelectedTimeScale),
                onLoading: () => context
                    .read(popularStateNotifierProvider)
                    .getMorePosts(_posts, _currentSelectedDate, _currentPage,
                        _currentSelectedTimeScale),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "Popular: ${DateFormat('MMM d, yyyy').format(_currentSelectedDate)}"),
                          ),
                          _buildToolRow(context),
                        ],
                      ),
                    ),
                    Consumer(builder: (context, watch, child) {
                      final state = watch(popularStateNotifierProvider.state);
                      return state.when(
                          initial: () => SliverPostGridPlaceHolder(),
                          loading: () => SliverPostGridPlaceHolder(),
                          fetched: (posts, page, date, scale) {
                            _currentPage = page;
                            _posts = posts;
                            return SliverPostGrid(
                              posts: posts,
                            );
                          },
                          error: (name, message) => SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    Center(child: Text(message)),
                                  ],
                                ),
                              ));
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleTimePick(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      theme: DatePickerTheme(),
      onConfirm: (time) => setState(() {
        _currentSelectedDate = time;
        context
            .read(popularStateNotifierProvider)
            .getPosts(_currentSelectedDate, 1, _currentSelectedTimeScale);
      }),
      currentTime: DateTime.now(),
    );
  }

  Widget _buildToolRow(BuildContext context) {
    return Row(
      children: [
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<TimeScale>(
                value: _currentSelectedTimeScale,
                icon: Icon(Icons.arrow_drop_down),
                onChanged: (value) => setState(() {
                  _currentSelectedTimeScale = value;
                  context.read(popularStateNotifierProvider).getPosts(
                      _currentSelectedDate, 1, _currentSelectedTimeScale);
                }),
                items: <DropdownMenuItem<TimeScale>>[
                  DropdownMenuItem(
                    value: TimeScale.day,
                    child: Text("Day"),
                  ),
                  DropdownMenuItem(
                    value: TimeScale.week,
                    child: Text("Week"),
                  ),
                  DropdownMenuItem(
                    value: TimeScale.month,
                    child: Text("Month"),
                  ),
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
                switch (_currentSelectedTimeScale) {
                  case TimeScale.day:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).subtract(days: 1);
                    break;
                  case TimeScale.week:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).subtract(weeks: 1);
                    break;
                  case TimeScale.month:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).subtract(months: 1);
                    break;
                  default:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).subtract(days: 1);
                    break;
                }
                setState(() {});
                context.read(popularStateNotifierProvider).getPosts(
                    _currentSelectedDate, 1, _currentSelectedTimeScale);
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                switch (_currentSelectedTimeScale) {
                  case TimeScale.day:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).add(days: 1);
                    break;
                  case TimeScale.week:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).add(weeks: 1);
                    break;
                  case TimeScale.month:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).add(months: 1);
                    break;
                  default:
                    _currentSelectedDate =
                        Jiffy(_currentSelectedDate).add(days: 1);
                    break;
                }
                setState(() {});
                context.read(popularStateNotifierProvider).getPosts(
                    _currentSelectedDate, 1, _currentSelectedTimeScale);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
