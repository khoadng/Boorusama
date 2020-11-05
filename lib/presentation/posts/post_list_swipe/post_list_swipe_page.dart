import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
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
  PostImageController _postImageController;

  @override
  void initState() {
    super.initState();
    _postImageController = PostImageController();
    _currentPostIndex = widget.initialPostIndex;
  }

  @override
  void dispose() {
    _postImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appbarActions = <Widget>[];

    if (widget.posts[_currentPostIndex].isTranslated) {
      appbarActions.add(IconButton(
          icon: Icon(Icons.translate),
          onPressed: () => _postImageController.toggleTranslationNotes()));
    }

    appbarActions.add(
      PopupMenuButton<PostAction>(
        offset: Offset(0, 200),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
          const PopupMenuItem<PostAction>(
            value: PostAction.foo,
            child: Text('Placeholder'),
          ),
        ],
      ),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: appbarActions,
        ),
        body: Scaffold(
          body: PostListSwipe(
            postImageController: _postImageController,
            posts: widget.posts,
            onPostChanged: (value) {
              //TODO: not to reconsider, kinda ugly
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _currentPostIndex = value;
                });
              });
              // _tags.clear();
            },
            initialPostIndex: _currentPostIndex,
          ),
        ),
      ),
    );
  }
}

enum PostAction { foo }
