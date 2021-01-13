import 'package:boorusama/application/post_detail/favorite/bloc/post_favorite_state_notifier.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/comment/comment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'widgets/post_tag_list.dart';

class PostInfoPage extends StatefulWidget {
  final Post post;
  final List<Tag> tags;

  const PostInfoPage({
    Key key,
    @required this.post,
    @required this.tags,
  }) : super(key: key);

  @override
  _PostInfoPageState createState() => _PostInfoPageState();
}

class _PostInfoPageState extends State<PostInfoPage> {
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
                      .read(postFavoriteStateNotifierProvider)
                      .favorite(widget.post.id);
                  // post.isFavorited = true;
                  _favCount++;
                  return Future(() => true);
                } else {
                  context
                      .read(postFavoriteStateNotifierProvider)
                      .unfavorite(widget.post.id);
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
