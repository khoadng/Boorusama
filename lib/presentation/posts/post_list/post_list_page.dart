import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/bottom_bar_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  // bool _isLoading;
  // final _loadingNotifier = ValueNotifier<bool>(false);
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _postListBloc = BlocProvider.of<PostListBloc>(context);
    // _loadingNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Boorusama")),
      resizeToAvoidBottomInset: false,
      body: Stack(fit: StackFit.expand, children: [
        buildList(),
        PostListSearchBar(
          onSearched: _handleSearched,
          // progress: _isLoading,
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
          return buildError();
        }
      },
    );
  }

  // Widget buildInitial() {
  //   return Center(child: PostListSearchBar(onSearched: _handleSearched));
  // }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildListWithData(BuildContext context, List<Post> posts) {
    _posts.addAll(posts);
    return PostList(
      posts: _posts,
      onMaxItemReached: _loadMorePosts,
      scrollThreshold: 0.8,
      scrollController: _scrollController,
    );
  }

  // Widget buildBottomLoading() {
  //   return BottomLoader();
  // }

  Widget buildError() {
    return Center(
      child: Text("OOPS something went wrong"),
    );
  }

  void _handleSearched(String query) {
    _currentSearchQuery = query;
    _posts.clear();
    // _loadingNotifier.value = true;
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
  }

  void _loadMorePosts(_) {
    _currentPage++;
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
  }
}
