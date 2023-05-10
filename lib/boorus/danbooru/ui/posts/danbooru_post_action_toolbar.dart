// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_vote_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/ui/posts.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/collection_utils.dart';

class DanbooruPostActionToolbar extends ConsumerWidget {
  const DanbooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFavoriteButton(context, authState),
          if (authState is Authenticated) _buildUpvoteButton(context),
          if (authState is Authenticated) _buildDownvoteButton(context),
          _buildCommentButton(context),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }

  Widget _buildUpvoteButton(BuildContext context) {
    return BlocBuilder<PostVoteCubit, PostVoteState>(
      builder: (context, state) {
        var voteState = VoteState.unvote;

        if (state is PostVoteLoaded) {
          voteState = state.postVotes
                  .firstOrNull((e) => e.postId == post.id)
                  ?.voteState ??
              VoteState.unvote;
        }
        return IconButton(
          icon: Icon(
            Icons.arrow_upward,
            color: voteState == VoteState.upvoted ? Colors.redAccent : null,
          ),
          onPressed: () {
            context.read<PostVoteCubit>().upvote(post.id);
          },
        );
      },
    );
  }

  Widget _buildDownvoteButton(BuildContext context) {
    return BlocBuilder<PostVoteCubit, PostVoteState>(
      builder: (context, state) {
        var voteState = VoteState.unvote;

        if (state is PostVoteLoaded) {
          voteState = state.postVotes
                  .firstOrNull((e) => e.postId == post.id)
                  ?.voteState ??
              VoteState.unvote;
        }

        return IconButton(
          icon: Icon(
            Icons.arrow_downward,
            color: voteState == VoteState.downvoted ? Colors.blueAccent : null,
          ),
          onPressed: () {
            context.read<PostVoteCubit>().downvote(post.id);
          },
        );
      },
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return IconButton(
      onPressed: () => goToCommentPage(context, post.id),
      icon: const FaIcon(
        FontAwesomeIcons.comment,
      ),
    );
  }

  Widget _buildFavoriteButton(
    BuildContext context,
    AuthenticationState authState,
  ) {
    return BlocBuilder<FavoritePostCubit, FavoritePostState>(
      builder: (context, state) {
        var isFaved = false;
        if (state is FavoritePostListSuccess) {
          isFaved = state.favorites[post.id] ?? false;
        }

        return IconButton(
          onPressed: () async {
            if (authState is Unauthenticated) {
              showSimpleSnackBar(
                context: context,
                content: const Text(
                  'post.detail.login_required_notice',
                ).tr(),
                duration: const Duration(seconds: 1),
              );

              return;
            }
            if (isFaved) {
              context.read<FavoritePostCubit>().removeFavorite(post.id);
            } else {
              context.read<FavoritePostCubit>().addFavorite(post.id);
            }
          },
          icon: isFaved
              ? const FaIcon(
                  FontAwesomeIcons.solidHeart,
                  color: Colors.red,
                )
              : const FaIcon(
                  FontAwesomeIcons.heart,
                ),
        );
      },
    );
  }
}
