import 'package:boorusama/application/posts/post_download/download_service.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:flutter/material.dart';

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
  IDownloadService _downloadService;

  @override
  void initState() {
    //TODO: use Bloc here
    super.initState();
    _downloadService = DownloadService();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _downloadService.init(Theme.of(context).platform);
    });
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO: handle permission denied
          _downloadService.download(
              widget.posts[_currentPostIndex].fullImageUri.toString());
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
