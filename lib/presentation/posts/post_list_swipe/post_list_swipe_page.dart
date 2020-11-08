import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/comments/comment_page.dart';
import 'package:boorusama/presentation/posts/post_detail/post_detail_page.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/custom_page_route.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_image_widget.dart';
import 'package:boorusama/presentation/posts/post_list_swipe/widgets/post_list_swipe_widget.dart';
import 'package:boorusama/presentation/posts/post_detail/widgets/post_tag_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostListSwipePage extends StatefulWidget {
  PostListSwipePage(
      {Key key, @required this.posts, this.initialPostIndex, this.postHeroTag})
      : super(key: key);

  final List<Post> posts;
  final int initialPostIndex;
  final String postHeroTag;

  @override
  _PostListSwipePageState createState() => _PostListSwipePageState();
}

class _PostListSwipePageState extends State<PostListSwipePage> {
  int _currentPostIndex;
  PostImageController _postImageController;
  List<Tag> _tags = <Tag>[];

  @override
  void initState() {
    super.initState();
    _postImageController = PostImageController();
    _currentPostIndex = widget.initialPostIndex;
    BlocProvider.of<TagListBloc>(context).add(
      GetTagList(widget.posts[_currentPostIndex].tagString.toCommaFormat(), 1),
    );
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
      IconButton(
        icon: Icon(Icons.info),
        onPressed: () => Navigator.push(context, FadePageRoute(builder: (_) {
          return PostDetailPage(
            post: widget.posts[_currentPostIndex],
            postHeroTag: widget.postHeroTag,
            tags: _tags,
          );
        })),
      ),
    );

    appbarActions.add(
      PopupMenuButton<PostAction>(
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
          const PopupMenuItem<PostAction>(
            value: PostAction.download,
            child: ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text("Download"),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: appbarActions,
      ),
      bottomNavigationBar: bottomAppBar(context),
      body: BlocListener<TagListBloc, TagListState>(
        listener: (context, state) {
          if (state is TagListLoaded) {
            setState(() {
              _tags = state.tags;
            });
          }
        },
        child: PostListSwipe(
          postHeroTag: widget.postHeroTag,
          postImageController: _postImageController,
          posts: widget.posts,
          onPostChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentPostIndex = value;
              });
            });

            BlocProvider.of<TagListBloc>(context).add(
              GetTagList(widget.posts[value].tagString.toCommaFormat(), 1),
            );
          },
          initialPostIndex: _currentPostIndex,
        ),
      ),
    );
  }

  Widget bottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CupertinoButton(
            child: Icon(
              CupertinoIcons.heart,
              size: 28,
              color: Colors.white70,
            ),
            onPressed: () => BlocProvider.of<PostFavoritesBloc>(context).add(
              AddToFavorites(widget.posts[_currentPostIndex].id),
            ),
          ),
          CupertinoButton(
            child: Icon(
              Icons.comment,
              size: 28,
              color: Colors.white70,
            ),
            onPressed: () {
              showBarModalBottomSheet(
                expand: false,
                context: context,
                builder: (context, controller) => CommentPage(
                  postId: widget.posts[_currentPostIndex].id,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

enum PostAction { download }
