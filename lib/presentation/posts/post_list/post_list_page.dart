import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListPage extends StatefulWidget {
  PostListPage({Key key}) : super(key: key);

  @override
  PostListPageState createState() => PostListPageState();
}

class PostListPageState extends State<PostListPage> {
  String _currentSearchQuery = "";
  int _currentPage = 1;
  final List<Post> posts = List<Post>();
  PostListBloc _postListBloc;
  PostDownloadBloc _postDownloadBloc;
  final ScrollController scrollController = new ScrollController();
  final FloatingSearchBarController searchBarController =
      new FloatingSearchBarController();

  //TODO: Move PostDownload to shared folder
  @override
  void initState() {
    super.initState();
    _postListBloc = BlocProvider.of<PostListBloc>(context);
    _postDownloadBloc = BlocProvider.of<PostDownloadBloc>(context);
    _postListBloc.add(GetPost("", 1));
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchBarController.dispose();
    super.dispose();
  }

  void handleSearched(String query) {
    _currentSearchQuery = query;
    posts.clear();
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
    scrollController.jumpTo(0.0);
  }

  void loadMorePosts(_) {
    _currentPage++;
    _postListBloc.add(GetPost(_currentSearchQuery, _currentPage));
  }

  void downloadAllPosts() {
    posts.forEach((post) {
      _postDownloadBloc.add(PostDownloadRequested(post: post));
    });
  }

  @override
  Widget build(BuildContext context) => PostListPageView(this);
}
