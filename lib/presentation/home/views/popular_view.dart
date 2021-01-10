import 'package:boorusama/application/posts/post_popular/bloc/post_popular_bloc.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/presentation/home/widgets/lists/sliver_image_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PopularView extends StatefulWidget {
  PopularView({
    Key key,
  }) : super(key: key);

  @override
  _PopularViewState createState() => _PopularViewState();
}

class _PopularViewState extends State<PopularView>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;
  TimeScale _currentSelectedTimeScale;
  int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    _currentSelectedTimeScale = TimeScale.day;
    _currentPage = 1;
    context.read<PostPopularBloc>().add(PostPopularEvent.requested(
        date: _currentSelectedDate,
        scale: _currentSelectedTimeScale,
        page: _currentPage));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            DatePicker.showDatePicker(
              context,
              theme: DatePickerTheme(),
              onConfirm: (time) {
                setState(() {
                  _currentSelectedDate = time;
                });
                context.read<PostPopularBloc>().add(PostPopularEvent.requested(
                    date: _currentSelectedDate,
                    scale: _currentSelectedTimeScale,
                    page: _currentPage));
              },
              currentTime: DateTime.now(),
            );
          },
          child: Icon(Icons.calendar_today),
        ),
        body: Builder(
          // This Builder is needed to provide a BuildContext that is "inside"
          // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
          // find the NestedScrollView.
          builder: (BuildContext context) {
            return BlocListener<PostPopularBloc, PostPopularState>(
              listener: (context, state) {
                state.maybeWhen(
                  fetched: (posts) => _refreshController.refreshCompleted(),
                  orElse: () {},
                );
              },
              child:
                  // state is AdditionalPostPopularFetched)
                  SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                header: const WaterDropMaterialHeader(),
                onRefresh: () => BlocProvider.of<PostPopularBloc>(context)
                    .add(PostPopularEvent.requested(
                  date: DateTime.now(),
                  scale: TimeScale.day,
                  page: 1,
                )),
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
                          Row(
                            children: [
                              Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButton<TimeScale>(
                                      value: _currentSelectedTimeScale,
                                      icon: Icon(Icons.arrow_drop_down),
                                      onChanged: (value) {
                                        setState(() {
                                          _currentSelectedTimeScale = value;
                                        });
                                        context.read<PostPopularBloc>().add(
                                            PostPopularEvent.requested(
                                                date: _currentSelectedDate,
                                                scale:
                                                    _currentSelectedTimeScale,
                                                page: _currentPage));
                                      },
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
                                      setState(() {
                                        switch (_currentSelectedTimeScale) {
                                          case TimeScale.day:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .subtract(days: 1);
                                            break;
                                          case TimeScale.week:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .subtract(weeks: 1);
                                            break;
                                          case TimeScale.month:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .subtract(months: 1);
                                            break;
                                          default:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .subtract(days: 1);
                                            break;
                                        }
                                      });
                                      context.read<PostPopularBloc>().add(
                                          PostPopularEvent.requested(
                                              date: _currentSelectedDate,
                                              scale: _currentSelectedTimeScale,
                                              page: _currentPage));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_right),
                                    onPressed: () {
                                      setState(() {
                                        switch (_currentSelectedTimeScale) {
                                          case TimeScale.day:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .add(days: 1);
                                            break;
                                          case TimeScale.week:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .add(weeks: 1);
                                            break;
                                          case TimeScale.month:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .add(months: 1);
                                            break;
                                          default:
                                            _currentSelectedDate =
                                                Jiffy(_currentSelectedDate)
                                                    .add(days: 1);
                                            break;
                                        }
                                      });
                                      context.read<PostPopularBloc>().add(
                                          PostPopularEvent.requested(
                                              date: _currentSelectedDate,
                                              scale: _currentSelectedTimeScale,
                                              page: _currentPage));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<PostPopularBloc, PostPopularState>(
                        builder: (context, state) {
                      return state.maybeWhen(
                        fetched: (posts) =>
                            SliverPostList(length: posts.length, posts: posts),
                        orElse: () => SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
