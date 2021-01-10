import 'package:boorusama/application/home/browse_all/browse_all_bloc.dart';
import 'package:boorusama/presentation/home/widgets/lists/refreshable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
