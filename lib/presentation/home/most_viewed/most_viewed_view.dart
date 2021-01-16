import 'package:boorusama/application/home/most_viewed/most_viewed_state_notifier.dart';
import 'package:boorusama/presentation/home/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final mostViewedStateNotifierProvider =
    StateNotifierProvider<MostViewedStateNotifier>(
        (ref) => MostViewedStateNotifier(ref));

class MostViewedView extends StatefulWidget {
  MostViewedView({Key key}) : super(key: key);

  @override
  _MostViewedViewState createState() => _MostViewedViewState();
}

class _MostViewedViewState extends State<MostViewedView>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();

    Future.delayed(
        Duration.zero,
        () => context
            .read(mostViewedStateNotifierProvider)
            .refresh(_currentSelectedDate));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderListener<MostViewedState>(
      provider: mostViewedStateNotifierProvider.state,
      onChange: (context, state) => state.maybeWhen(
          fetched: (posts, date) => setState(() {
                _currentSelectedDate = date;
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
                header: const WaterDropMaterialHeader(),
                onRefresh: () => context
                    .read(mostViewedStateNotifierProvider)
                    .refresh(_currentSelectedDate),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "Most viewed: ${DateFormat('MMM d, yyyy').format(_currentSelectedDate)}"),
                          ),
                          _buildToolRow(context),
                        ],
                      ),
                    ),
                    Consumer(builder: (context, watch, child) {
                      final state =
                          watch(mostViewedStateNotifierProvider.state);
                      return state.when(
                        initial: () => SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(),
                            ],
                          ),
                        ),
                        loading: () => SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(child: CircularProgressIndicator()),
                            ],
                          ),
                        ),
                        fetched: (posts, date) => SliverPostGrid(
                          posts: posts,
                        ),
                        error: (name, message) => SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(child: Text(message)),
                            ],
                          ),
                        ),
                      );
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
            .read(mostViewedStateNotifierProvider)
            .getPosts(_currentSelectedDate);
      }),
      currentTime: DateTime.now(),
    );
  }

  Widget _buildToolRow(BuildContext context) {
    return Row(
      children: [
        ButtonBar(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                _currentSelectedDate =
                    Jiffy(_currentSelectedDate).subtract(days: 1);

                setState(() {});
                context
                    .read(mostViewedStateNotifierProvider)
                    .getPosts(_currentSelectedDate);
              },
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                _currentSelectedDate = Jiffy(_currentSelectedDate).add(days: 1);

                setState(() {});
                context
                    .read(mostViewedStateNotifierProvider)
                    .getPosts(_currentSelectedDate);
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
