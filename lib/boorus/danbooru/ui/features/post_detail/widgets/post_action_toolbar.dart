// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_share_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_vote_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/modal_share.dart';
import 'package:boorusama/utils/collection_utils.dart';

class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, authState) => ButtonBar(
          buttonPadding: EdgeInsets.zero,
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFavoriteButton(context, authState),
            if (authState is Authenticated) _buildUpvoteButton(context),
            if (authState is Authenticated) _buildDownvoteButton(context),
            _buildCommentButton(context),
            _buildDownloadButton(),
            _buildShareButton(context),
          ],
        ),
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

  Widget _buildDownloadButton() {
    return DownloadProviderWidget(
      builder: (context, download) => IconButton(
        onPressed: () => download(post),
        icon: const FaIcon(FontAwesomeIcons.download),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return BlocBuilder<PostShareCubit, PostShareState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => Screen.of(context).size == ScreenSize.small
              ? showMaterialModalBottomSheet(
                  expand: false,
                  context: context,
                  barrierColor: Colors.black45,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ModalShare(
                    booruLink: state.booruLink,
                    sourceLink: state.sourceLink,
                    onTap: Share.share,
                    onTapFile: (filePath) =>
                        Share.shareXFiles([XFile(filePath)]),
                    imagePath: state.booruImagePath,
                  ),
                )
              : showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: ModalShare(
                      booruLink: state.booruLink,
                      sourceLink: state.sourceLink,
                      onTap: Share.share,
                      onTapFile: (filePath) =>
                          Share.shareXFiles([XFile(filePath)]),
                      imagePath: state.booruImagePath,
                    ),
                  ),
                ),
          icon: const FaIcon(
            FontAwesomeIcons.share,
          ),
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
