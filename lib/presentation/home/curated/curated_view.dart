import 'package:boorusama/application/home/curated/curated_bloc.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/presentation/home/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CuratedView extends StatefulWidget {
  CuratedView({
    Key key,
  }) : super(key: key);

  @override
  _CuratedViewState createState() => _CuratedViewState();
}

class _CuratedViewState extends State<CuratedView>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;
  TimeScale _currentSelectedTimeScale;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    _currentSelectedTimeScale = TimeScale.day;
    BlocProvider.of<CuratedBloc>(context).add(CuratedEvent.started());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<CuratedBloc, CuratedState>(
      listener: (context, state) {
        setState(() {
          _currentSelectedDate = state.selectedTime;
          _currentSelectedTimeScale = state.selectedTimeScale;

          _isRefreshing = state.isRefreshing;
          _isLoadingMore = state.isLoadingMore;

          if (!_isRefreshing) {
            _refreshController.refreshCompleted();
          }

          if (!_isLoadingMore) {
            _refreshController.loadComplete();
          }
        });
      },
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
                onRefresh: () => BlocProvider.of<CuratedBloc>(context)
                    .add(CuratedEvent.refreshed()),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "Curated: ${DateFormat('MMM d, yyyy').format(_currentSelectedDate)}"),
                          ),
                          _buildToolRow(context),
                        ],
                      ),
                    ),
                    BlocBuilder<CuratedBloc, CuratedState>(
                        builder: (context, state) {
                      if (state.error != null) {
                        return SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(child: Text(state.error.message)),
                            ],
                          ),
                        );
                      } else if (state.isLoadingNew) {
                        return SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(child: CircularProgressIndicator()),
                            ],
                          ),
                        );
                      } else {
                        return SliverPostList(
                          length: state.posts.length,
                          posts: state.posts,
                        );
                      }
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
      onConfirm: (time) => BlocProvider.of<CuratedBloc>(context)
          .add(CuratedEvent.timeChanged(date: time)),
      currentTime: DateTime.now(),
    );
  }

  Row _buildToolRow(BuildContext context) {
    return Row(
      children: [
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<TimeScale>(
                value: _currentSelectedTimeScale,
                icon: Icon(Icons.arrow_drop_down),
                onChanged: (value) => BlocProvider.of<CuratedBloc>(context)
                    .add(CuratedEvent.timeScaleChanged(scale: value)),
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
              onPressed: () => BlocProvider.of<CuratedBloc>(context)
                  .add(CuratedEvent.timeBackwarded()),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () => BlocProvider.of<CuratedBloc>(context)
                  .add(CuratedEvent.timeForwarded()),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
