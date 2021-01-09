import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/comments/comment_page.dart';
import 'package:boorusama/presentation/posts/post_detail/widgets/post_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final List<Tag> tags;

  const PostDetailPage({
    Key key,
    @required this.post,
    @required this.tags,
  }) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int _favCount;

  @override
  void initState() {
    super.initState();
    _favCount = widget.post.favCount;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PostTagList(tags: widget.tags),
        ButtonBar(
          children: <Widget>[
            LikeButton(
              likeCount: _favCount,
              onTap: (isLiked) {
                //TODO: check for success here
                if (!isLiked) {
                  context
                      .read<PostFavoritesBloc>()
                      .add(PostFavoritesEvent.added(postId: widget.post.id));
                  // post.isFavorited = true;
                  _favCount++;
                  return Future(() => true);
                } else {
                  context
                      .read<PostFavoritesBloc>()
                      .add(PostFavoritesEvent.removed(postId: widget.post.id));
                  // widget.post.isFavorited = false;
                  _favCount--;
                  return Future(() => false);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                showBarModalBottomSheet(
                  expand: false,
                  context: context,
                  builder: (context, controller) => CommentPage(
                    postId: widget.post.id,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
