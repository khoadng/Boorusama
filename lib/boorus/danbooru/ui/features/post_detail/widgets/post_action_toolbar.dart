// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'modal_share.dart';

class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    super.key,
    required this.postData,
    required this.imagePath,
  });

  final DanbooruPostData postData;
  final String? imagePath;

  DanbooruPost get post => postData.post;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
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
    );
  }

  Widget _buildUpvoteButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_upward,
        color:
            postData.voteState == VoteState.upvoted ? Colors.redAccent : null,
      ),
      onPressed: () {
        context.read<PostDetailBloc>().add(const PostDetailUpvoted());
      },
    );
  }

  Widget _buildDownvoteButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_downward,
        color:
            postData.voteState == VoteState.downvoted ? Colors.redAccent : null,
      ),
      onPressed: () {
        context.read<PostDetailBloc>().add(const PostDetailDownvoted());
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
    final modal = BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (context, state) {
        final booru = state.booru ?? safebooru();

        return ModalShare(
          endpoint: booru.url,
          onTap: Share.share,
          onTapFile: (filePath) => Share.shareXFiles([XFile(filePath)]),
          post: post,
          imagePath: imagePath,
        );
      },
    );

    return IconButton(
      onPressed: () => Screen.of(context).size == ScreenSize.small
          ? showMaterialModalBottomSheet(
              expand: false,
              context: context,
              barrierColor: Colors.black45,
              backgroundColor: Colors.transparent,
              builder: (context) => modal,
            )
          : showDialog(
              context: context,
              builder: (context) => AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: modal,
              ),
            ),
      icon: const FaIcon(
        FontAwesomeIcons.share,
      ),
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
        }

        context
            .read<PostDetailBloc>()
            .add(PostDetailFavoritesChanged(favorite: !postData.isFavorited));
      },
      icon: postData.isFavorited
          ? const FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Colors.red,
            )
          : const FaIcon(
              FontAwesomeIcons.heart,
            ),
    );
  }
}
