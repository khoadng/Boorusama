import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/home/widgets/lists/refreshable_list.dart';
import 'package:boorusama/presentation/services/debouncer/debouncer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'bloc/browse_all_bloc.dart';

class BrowseAllView extends StatefulWidget {
  BrowseAllView({
    Key key,
    this.initialQuery,
  }) : super(key: key);

  final String initialQuery;

  @override
  _BrowseAllViewState createState() => _BrowseAllViewState();
}

class _BrowseAllViewState extends State<BrowseAllView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isRefreshing = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<BrowseAllBloc, BrowseAllState>(
      listener: (context, state) {
        setState(() {
          _isRefreshing = state.isRefreshing;
          _isLoadingMore = state.isLoadingMore;

          if (!_isRefreshing) {
            _refreshController.refreshCompleted();
          }

          if (!_isLoadingMore) {
            _refreshController.loadComplete();
          }
        });

        // if (state.error != null) {
        //   // var flush;
        //   Flushbar(
        //     icon: Icon(
        //       Icons.info_outline,
        //       color: Theme.of(context).accentColor,
        //     ),
        //     leftBarIndicatorColor: Theme.of(context).accentColor,
        //     title: state.error.name,
        //     message: state.error.message,
        //     // mainButton: FlatButton(
        //     //   onPressed: () {
        //     //     flush.dismiss(true);
        //     //   },
        //     //   child: Text("OK"),
        //     // ),
        //   )..show(context);
        // }
      },
      builder: (context, state) {
        if (state.error != null) {
          return Center(
            child: Text(state.error.message),
          );
        } else if (state.isLoadingNew || state.isSearching) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: _downloadAllPosts,
              heroTag: null,
              child: Icon(Icons.download_sharp),
            ),
            body: RefreshableList(
              posts: state.posts,
              onLoadMore: () => BlocProvider.of<BrowseAllBloc>(context)
                  .add(BrowseAllEvent.loadedMore()),
              onRefresh: () => BlocProvider.of<BrowseAllBloc>(context)
                  .add(BrowseAllEvent.refreshed()),
              refreshController: _refreshController,
            ),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _downloadAllPosts() {
    // _posts.forEach((post) {
    //   context
    //       .read<PostDownloadBloc>()
    //       .add(PostDownloadEvent.downloaded(post: post));
    // });
  }
}
