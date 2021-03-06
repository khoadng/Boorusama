// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';

final _commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final commentRepo = ref.watch(commentProvider);
  final userRepo = ref.watch(userProvider);
  final dtos = await commentRepo.getCommentsFromPostId(postId);
  final comments = dtos
      .where((e) => e.creator_id != null)
      .toList()
      .map((dto) => dto.toEntity())
      .toList();

  final userList = comments.map((e) => e.creatorId).toSet().toList();
  final users = await userRepo.getUsersByIdStringComma(userList.join(","));

  final commentsWithAuthor =
      (comments..sort((a, b) => a.id.compareTo(b.id))).map((comment) {
    final author = users.where((user) => user.id == comment.creatorId).first;
    return comment.copyWith(author: author);
  }).toList();

  /// Cache the artist posts once it was successfully obtained.
  ref.maintainState = true;

  return commentsWithAuthor;
});

class PostActionToolbar extends HookWidget {
  const PostActionToolbar({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final comments = useProvider(_commentsProvider(post.id));
    final isLoggedIn = useProvider(isLoggedInProvider);

    bool displayNoticeIfNotLoggedIn() {
      if (!isLoggedIn) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          content: Text(
            'You need to log in to perform this action',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return false;
      }
      return true;
    }

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LikeButton(
          // isLiked: post.isFavorited,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          likeCount: post.upScore,
          likeBuilder: (isLiked) => FaIcon(isLiked
              ? FontAwesomeIcons.solidThumbsUp
              : FontAwesomeIcons.thumbsUp),
          onTap: (isLiked) {
            return Future.value(displayNoticeIfNotLoggedIn());
          },
        ),
        LikeButton(
          // isLiked: post.isFavorited,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          likeCount: post.downScore,
          likeBuilder: (isLiked) => FaIcon(isLiked
              ? FontAwesomeIcons.solidThumbsDown
              : FontAwesomeIcons.thumbsDown),
          onTap: (isLiked) {
            return Future.value(displayNoticeIfNotLoggedIn());
          },
        ),
        LikeButton(
          isLiked: post.isFavorited,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          likeCount: post.favCount,
          likeBuilder: (isLiked) => FaIcon(
            isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            color: isLiked ? Colors.red : Colors.white,
          ),
          onTap: (isLiked) {
            final loggedIn = displayNoticeIfNotLoggedIn();

            if (!loggedIn) return Future.value(false);

            //TODO: check for success here
            if (!isLiked) {
              context.read(favoriteProvider).addToFavorites(post.id);

              return Future(() => true);
            } else {
              context.read(favoriteProvider).removeFromFavorites(post.id);
              return Future(() => false);
            }
          },
        ),
        LikeButton(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // likeCount: detail.postStatistics.commentCount,
          likeBuilder: (isLiked) => FaIcon(
            FontAwesomeIcons.comment,
            color: Colors.white,
          ),
          onTap: (isLiked) => showBarModalBottomSheet(
            expand: false,
            context: context,
            builder: (context) => CommentPage(
              comments: comments,
              postId: post.id,
            ),
          ),
        ),
      ],
    );
  }
}
