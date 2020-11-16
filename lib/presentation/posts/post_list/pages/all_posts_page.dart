import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/lists/sliver_image_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllPostsPage extends StatefulWidget {
  AllPostsPage({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final List<Post> posts;

  @override
  _AllPostsPageState createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
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
                if (state is PostListLoaded ||
                    state is AddtionalPostListLoaded) {
                  return SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    header: const WaterDropMaterialHeader(),
                    onRefresh: () => BlocProvider.of<PostSearchBloc>(context)
                        .add(PostSearchEvent.postSearched(query: "", page: 1)),
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
                            length: widget.posts.length, posts: widget.posts),
                      ],
                    ),
                  );
                } else if (state is PostListError) {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                } else {
                  return Center(child: Text("Nothing's here"));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
