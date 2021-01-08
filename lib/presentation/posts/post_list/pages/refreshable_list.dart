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
    @required this.onLoadMore,
    @required this.refreshController,
  }) : super(key: key);

  final List<Post> posts;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
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
                  _refreshController.loadComplete();
                },
                orElse: () {},
              );
            },
            child: _buildBody(
              context,
              widget.posts,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Post> posts) {
    if (posts.isNotEmpty) {
      return SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropMaterialHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => widget.onRefresh(),
        onLoading: () => widget.onLoadMore(),
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
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
