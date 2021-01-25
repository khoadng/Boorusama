// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/most_viewed/most_viewed_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';

final _posts = Provider<List<Post>>((ref) {
  return ref.watch(mostViewedStateNotifierProvider.state).posts;
});
final _mostViewedPostProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<PostState>((ref) {
  return ref.watch(mostViewedStateNotifierProvider.state).postsState;
});
final _postsStateProvider = Provider<PostState>((ref) {
  return ref.watch(_postsState);
});

final _date = Provider<DateTime>((ref) {
  return ref.watch(mostViewedStateNotifierProvider.state).selectedDate;
});
final _dateProvider = Provider<DateTime>((ref) {
  final date = ref.watch(_date);

  Future.delayed(Duration.zero,
      () => ref.watch(mostViewedStateNotifierProvider).refresh());

  return date;
});

class MostViewedView extends HookWidget {
  const MostViewedView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
    final scrollController = useScrollController();
    final refreshController =
        useState(RefreshController(initialRefresh: false));

    final selectedDate = useProvider(_dateProvider);
    final posts = useProvider(_mostViewedPostProvider);
    final postsState = useProvider(_postsStateProvider);

    useEffect(() {
      Future.microtask(
          () => context.read(mostViewedStateNotifierProvider).refresh());
      return () => {};
    }, []);

    return ProviderListener<PostState>(
      provider: _postsState,
      onChange: (context, state) {
        state.maybeWhen(
          fetched: () {
            refreshController.value.refreshCompleted();
          },
          error: () => Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Something went wrong"))),
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullDown: true,
        header: const MaterialClassicHeader(),
        onRefresh: () =>
            context.read(mostViewedStateNotifierProvider).refresh(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonBar(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_left),
                            onPressed: () => context
                                .read(mostViewedStateNotifierProvider)
                                .reverseOneTimeUnit(),
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
                                context
                                    .read(mostViewedStateNotifierProvider)
                                    .updateDate(time);
                              },
                              currentTime: DateTime.now(),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                    "${DateFormat('MMM d, yyyy').format(selectedDate)}"),
                                Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: () => context
                                .read(mostViewedStateNotifierProvider)
                                .forwardOneTimeUnit(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            postsState.maybeWhen(
              refreshing: () =>
                  SliverPostGridPlaceHolder(scrollController: scrollController),
              orElse: () => SliverPostGrid(
                key: gridKey.value,
                posts: posts,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
