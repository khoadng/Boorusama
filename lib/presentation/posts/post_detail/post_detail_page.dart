import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/presentation/comments/comment_page.dart';
import 'package:boorusama/presentation/posts/post_detail/widgets/post_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final String postHeroTag;
  final List<Tag> tags;

  const PostDetailPage({
    Key key,
    @required this.post,
    @required this.tags,
    @required this.postHeroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PostTagList(tags: tags),
        ButtonBar(
          children: <Widget>[
            LikeButton(
              isLiked: post.isFavorited,
              likeCount: post.favCount,
              onTap: (isLiked) {
                //TODO: check for success here
                if (!isLiked) {
                  context
                      .read<PostFavoritesBloc>()
                      .add(PostFavoritesEvent.added(postId: post.id));
                  post.isFavorited = true;
                  post.favCount++;
                  return Future(() => true);
                } else {
                  context
                      .read<PostFavoritesBloc>()
                      .add(PostFavoritesEvent.removed(postId: post.id));
                  post.isFavorited = false;
                  post.favCount--;
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
                    postId: post.id,
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
