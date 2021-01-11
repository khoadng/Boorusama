import 'package:boorusama/application/home/most_viewed/most_viewed_bloc.dart';
import 'package:boorusama/presentation/home/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MostViewedView extends StatefulWidget {
  MostViewedView({
    Key key,
  }) : super(key: key);

  @override
  _MostViewedViewState createState() => _MostViewedViewState();
}

class _MostViewedViewState extends State<MostViewedView>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    BlocProvider.of<MostViewedBloc>(context).add(MostViewedEvent.started());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MostViewedBloc, MostViewedState>(
      listener: (context, state) {
        setState(() {
          _currentSelectedDate = state.selectedTime;

          _isRefreshing = state.isRefreshing;

          if (!_isRefreshing) {
            _refreshController.refreshCompleted();
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
                header: const WaterDropMaterialHeader(),
                onRefresh: () => BlocProvider.of<MostViewedBloc>(context)
                    .add(MostViewedEvent.refreshed()),
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
                    BlocBuilder<MostViewedBloc, MostViewedState>(
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
      onConfirm: (time) => BlocProvider.of<MostViewedBloc>(context)
          .add(MostViewedEvent.timeChanged(date: time)),
      currentTime: DateTime.now(),
    );
  }

  Row _buildToolRow(BuildContext context) {
    return Row(
      children: [
        ButtonBar(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () => BlocProvider.of<MostViewedBloc>(context)
                  .add(MostViewedEvent.timeBackwarded()),
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () => BlocProvider.of<MostViewedBloc>(context)
                  .add(MostViewedEvent.timeForwarded()),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
