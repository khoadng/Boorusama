import 'package:boorusama/application/posts/post_most_viewed/bloc/post_most_viewed_bloc.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/lists/sliver_image_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MostViewedPage extends StatefulWidget {
  MostViewedPage({
    Key key,
  }) : super(key: key);

  @override
  _MostViewedPageState createState() => _MostViewedPageState();
}

class _MostViewedPageState extends State<MostViewedPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = DateTime.now();
    context.read<PostMostViewedBloc>().add(
          PostMostViewedEvent.requested(
            date: _currentSelectedDate,
          ),
        );
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
                context
                    .read<PostMostViewedBloc>()
                    .add(PostMostViewedEvent.requested(
                      date: _currentSelectedDate,
                    ));
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
            return BlocListener<PostMostViewedBloc, PostMostViewedState>(
              listener: (context, state) {
                state.maybeWhen(
                  fetched: (posts) => _refreshController.refreshCompleted(),
                  orElse: () {},
                );
              },
              child:
                  // state is AdditionalPostMostViewedFetched)
                  SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                header: const WaterDropMaterialHeader(),
                onRefresh: () => BlocProvider.of<PostMostViewedBloc>(context)
                    .add(PostMostViewedEvent.requested(
                  date: DateTime.now(),
                )),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "Most Viewed: ${DateFormat('MMM d, yyyy').format(_currentSelectedDate)}"),
                          ),
                          Row(
                            children: [
                              ButtonBar(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_left),
                                    onPressed: () {
                                      setState(() {
                                        _currentSelectedDate =
                                            Jiffy(_currentSelectedDate)
                                                .subtract(days: 1);
                                      });
                                      context.read<PostMostViewedBloc>().add(
                                            PostMostViewedEvent.requested(
                                              date: _currentSelectedDate,
                                            ),
                                          );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_right),
                                    onPressed: () {
                                      setState(() {
                                        _currentSelectedDate =
                                            Jiffy(_currentSelectedDate)
                                                .add(days: 1);
                                      });
                                      context.read<PostMostViewedBloc>().add(
                                            PostMostViewedEvent.requested(
                                              date: _currentSelectedDate,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<PostMostViewedBloc, PostMostViewedState>(
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
