import 'package:boorusama/application/home/most_viewed/most_viewed_state_notifier.dart';
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

final mostViewedStateNotifierProvider =
    StateNotifierProvider<MostViewedStateNotifier>(
        (ref) => MostViewedStateNotifier(ref));

class MostViewedView extends HookWidget {
  const MostViewedView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridKey = useState(GlobalKey());
    final selectedDate = useState(DateTime.now());
    final currentPosts = useState(<Post>[]);
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final mostViewedState = useProvider(mostViewedStateNotifierProvider.state);

    useEffect(() {
      Future.microtask(() => context
          .read(mostViewedStateNotifierProvider)
          .refresh(selectedDate.value));
      return () => {};
    }, []);

    return ProviderListener<MostViewedState>(
      provider: mostViewedStateNotifierProvider.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts) {
              refreshController.value.refreshCompleted();
              currentPosts.value.addAll(posts);
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
                    .read(mostViewedStateNotifierProvider)
                    .getPosts(selectedDate.value);
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
                header: const WaterDropMaterialHeader(),
                onRefresh: () {
                  currentPosts.value.clear();
                  context
                      .read(mostViewedStateNotifierProvider)
                      .refresh(selectedDate.value);
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                                "${I18n.of(context).postCategoriesMostViewed}: ${DateFormat('MMM d, yyyy').format(selectedDate.value)}"),
                          ),
                          Row(
                            children: [
                              ButtonBar(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_left),
                                    onPressed: () {
                                      selectedDate.value =
                                          Jiffy(selectedDate.value)
                                              .subtract(days: 1);
                                      context
                                          .read(mostViewedStateNotifierProvider)
                                          .getPosts(selectedDate.value);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_right),
                                    onPressed: () {
                                      selectedDate.value =
                                          Jiffy(selectedDate.value)
                                              .add(days: 1);
                                      context
                                          .read(mostViewedStateNotifierProvider)
                                          .getPosts(selectedDate.value);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    mostViewedState.when(
                      initial: () => SliverPostGridPlaceHolder(),
                      loading: () => SliverPostGridPlaceHolder(),
                      fetched: (posts) => SliverPostGrid(
                        key: gridKey.value,
                        posts: posts,
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
