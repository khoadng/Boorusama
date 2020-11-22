import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/lists/sliver_image_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableList extends StatefulWidget {
  RefreshableList({
    Key key,
    @required this.posts,
    @required this.onRefresh,
    @required this.refreshController,
  }) : super(key: key);

  final List<Post> posts;
  final VoidCallback onRefresh;
  final RefreshController refreshController;
  @override
  _RefreshableListState createState() => _RefreshableListState();
}

class _RefreshableListState extends State<RefreshableList> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        // This Builder is needed to provide a BuildContext that is "inside"
        // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
        // find the NestedScrollView.
        builder: (BuildContext context) {
          return BlocListener<PostSearchBloc, PostSearchState>(
            listener: (context, state) {
              state.maybeWhen(
                success: (posts, query, page) {
                  _refreshController.refreshCompleted();
                },
                orElse: () {},
              );
            },
            child: BlocBuilder<PostListBloc, PostListState>(
              builder: (context, state) {
                return state.when(
                  empty: () => Center(child: Text("Nothing's here")),
                  fetched: (posts) => _buildSmartRefresher(context, posts),
                  fetchedMore: (posts) => _buildSmartRefresher(context, posts),
                  error: (error, message) => Center(
                    child: Text("Something went wrong"),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartRefresher(BuildContext context, List<Post> posts) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      header: const WaterDropMaterialHeader(),
      onRefresh: () => widget.onRefresh(),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.all(2.0),
                ),
              ],
            ),
          ),
          SliverPostList(
            length: posts.length,
            posts: posts,
          ),
        ],
      ),
    );
  }
}
