import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/bottom_bar_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListPage extends StatefulWidget {
  PostListPage({Key key}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  String _currentSearchQuery = "";
  int _currentPage = 1;
  final List<Post> _posts = List<Post>();
  PostListBloc _postListBloc;
  final ScrollController _scrollController = new ScrollController();
  final FloatingSearchBarController _searchBarController =
      new FloatingSearchBarController();

  @override
  void initState() {
    super.initState();
    _postListBloc = BlocProvider.of<PostListBloc>(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff424242),
      resizeToAvoidBottomInset: false,
      body: Stack(fit: StackFit.expand, children: [
        buildList(),
        PostListSearchBar(
          controller: _searchBarController,
          onSearched: _handleSearched,
        ),
      ]),
      bottomNavigationBar: BottomBar(),
    );
  }

  Widget buildList() {
    return BlocBuilder<PostListBloc, PostListState>(
      builder: (context, state) {
        // if (state is PostListInitial) {
        //   return buildInitial();
        // } else
        if (state is PostListLoading) {
          return buildLoading();
        } else if (state is PostListLoaded) {
          // _loadingNotifier.value = false;
          return buildListWithData(context, state.posts);
          // } else if (state is PostListAdditionalLoading) {
          //   return buildBottomLoading();
        } else {
          return Center(child: Text("Nothing here"));
        }
      },
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildListWithData(BuildContext context, List<Post> posts) {
    _posts.addAll(posts);
    return PostList(
      posts: _posts,
      onScrollDirectionChanged: (value) => value == ScrollDirection.forward
          ? _searchBarController.show()
          : _searchBarController.hide(),
      onMaxItemReached: _loadMorePosts,
      scrollThreshold: 0.8,
      scrollController: _scrollController,
    );
  }

  Widget buildError() {
    return Center(
      child: Text("OOPS something went wrong"),
    );
  }

  void _handleSearched(String query) {
    _currentSearchQuery = query;
    _posts.clear();
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
  }

  void _loadMorePosts(_) {
    _currentPage++;
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
  }
}
