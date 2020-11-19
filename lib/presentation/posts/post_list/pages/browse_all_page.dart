import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:boorusama/presentation/services/debouncer/debouncer.dart';
import 'package:boorusama/presentation/ui/bottom_bar_widget.dart';
import 'package:boorusama/presentation/ui/drawer/side_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../post_list.dart';

class BrowseAllPage extends StatefulWidget {
  BrowseAllPage({Key key}) : super(key: key);

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _BrowseAllPageState createState() => _BrowseAllPageState();
}

class _BrowseAllPageState extends State<BrowseAllPage> {
  String _currentSearchQuery = "";
  int _currentPage = 1;
  int _currentTab = 0;
  final List<Post> _posts = List<Post>();
  final ScrollController _scrollController = new ScrollController();
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 1));

  Account _account;

  @override
  void initState() {
    super.initState();
    context
        .read<PostSearchBloc>()
        .add(PostSearchEvent.postSearched(query: "", page: 1));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearched(String query) {
    _currentSearchQuery = query;
    _currentPage = 1;
    _posts.clear();
    context.read<PostSearchBloc>().add(PostSearchEvent.postSearched(
        query: _currentSearchQuery, page: _currentPage));
    _scrollController.jumpTo(0.0);
  }

  void _handleTabChanged(int tabIndex) {
    setState(() {
      _currentTab = tabIndex;
    });
  }

  void _loadMorePosts() {
    _debouncer(() {
      _currentPage++;
      context.read<PostSearchBloc>().add(PostSearchEvent.postSearched(
          query: _currentSearchQuery, page: _currentPage));
    });
  }

  void _assignTagQuery(String query) {
    _currentSearchQuery = query;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() {
            _account = state.account;
          });
        } else if (state is Unauthenticated) {
          //TODO: dirty solution, unused parameter
          setState(() {
            _account = null;
          });
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: widget.scaffoldKey,
          drawer: SideBarMenu(
            account: _account,
          ),
          resizeToAvoidBottomInset: false,
          body: _getPage(_currentTab, context),
          bottomNavigationBar: BottomBar(
            onTabChanged: (value) => _handleTabChanged(value),
          ),
        ),
      ),
    );
  }

  //TODO: refactor
  Widget _getPage(int tabIndex, BuildContext context) {
    switch (tabIndex) {
      case 0:
        return Stack(
          fit: StackFit.expand,
          children: [
            buildList(),
            BlocBuilder<PostSearchBloc, PostSearchState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => Positioned(
                    bottom: 0,
                    child: Container(
                      height: 3,
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                    ),
                  ),
                  orElse: () => Center(),
                );
              },
            ),
          ],
        );
      case 1:
        return PostDownloadGalleryPage();
    }
  }

  Widget buildList() {
    return BlocListener<PostSearchBloc, PostSearchState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          success: (posts, query, page) => _assignTagQuery(query),
          error: (error, message) {
            var flush;
            flush = Flushbar(
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
              leftBarIndicatorColor: Theme.of(context).accentColor,
              title: error,
              message: message,
              mainButton: FlatButton(
                onPressed: () {
                  flush.dismiss(true);
                  _handleSearched("");
                },
                child: Text("OK"),
              ),
            )..show(context);
          },
        );
      },
      child: BlocListener<PostListBloc, PostListState>(
        listener: (context, state) {
          state.maybeWhen(
            fetched: (posts) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0.0);
              }
              _posts.clear();
              _posts.addAll(posts);
            },
            fetchedMore: (posts) => _posts.addAll(posts),
            orElse: () {},
          );
        },
        child: PostList(
          posts: _posts,
          onMenuTap: () => widget.scaffoldKey.currentState.openDrawer(),
          onMaxItemReached: _loadMorePosts,
          onSearched: (query) => _handleSearched(query),
          scrollThreshold: 1,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}
