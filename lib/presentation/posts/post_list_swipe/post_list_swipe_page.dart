import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostListSwipePage extends StatefulWidget {
  PostListSwipePage({Key key, @required this.posts, this.initialPostIndex})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;

  @override
  _PostListSwipePageState createState() => _PostListSwipePageState();
}

class _PostListSwipePageState extends State<PostListSwipePage> {
  int _currentPostIndex;
  PostDownloadBloc _postDownloadBloc;

  @override
  void initState() {
    super.initState();
    _postDownloadBloc = BlocProvider.of<PostDownloadBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _postDownloadBloc.add(
              PostDownloadRequested(post: widget.posts[_currentPostIndex]));
        },
        child: const Icon(Icons.download_rounded),
      ),
      body: PostListSwipe(
        posts: widget.posts,
        onPostChanged: (value) => _currentPostIndex = value,
        initialPostIndex: widget.initialPostIndex,
      ),
    );
  }
}
