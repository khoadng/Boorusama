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
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/comment/comment_page.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';

class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    Key? key,
    required this.post,
    required this.imagePath,
  }) : super(key: key);

  final Post post;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) => ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFavoriteButton(authState),
          if (authState is Authenticated) _buildUpvoteButton(),
          if (authState is Authenticated) _buildDownvoteButton(),
          _buildCommentButton(context),
          _buildDownloadButton(),
          _buildShareButton(context),
        ],
      ),
    );
  }

  Widget _buildUpvoteButton() {
    return BlocBuilder<PostVoteBloc, PostVoteState>(
      builder: (context, state) => IconButton(
        icon: Icon(
          Icons.arrow_upward,
          color: state.state == VoteState.upvoted ? Colors.redAccent : null,
        ),
        onPressed: () {
          _onPressedWithLoadingToast(
            context: context,
            status: state.status,
            success: () => context
                .read<PostVoteBloc>()
                .add(PostVoteUpvoted(postId: post.id)),
          );
        },
      ),
    );
  }

  Widget _buildDownvoteButton() {
    return BlocBuilder<PostVoteBloc, PostVoteState>(
      builder: (context, state) => IconButton(
        icon: Icon(
          Icons.arrow_downward,
          color: state.state == VoteState.downvoted ? Colors.redAccent : null,
        ),
        onPressed: () {
          _onPressedWithLoadingToast(
            context: context,
            status: state.status,
            success: () => context
                .read<PostVoteBloc>()
                .add(PostVoteDownvoted(postId: post.id)),
          );
        },
      ),
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
    final modal = BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
      builder: (context, state) {
        return ModalShare(
          endpoint: state.booru.url,
          onTap: Share.share,
          onTapFile: (filePath) => Share.shareFiles([filePath]),
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
        FontAwesomeIcons.shareFromSquare,
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return IconButton(
      onPressed: () => Screen.of(context).size == ScreenSize.small
          ? showBarModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => CommentPage(
                postId: post.id,
              ),
            )
          : showSideSheetFromRight(
              width: MediaQuery.of(context).size.width * 0.41,
              body: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top),
                  child: Column(
                    children: [
                      Container(
                        height: kToolbarHeight * 0.8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              'comment.comments',
                              style: Theme.of(context).textTheme.headline6,
                            ).tr(),
                            const Spacer(),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: Navigator.of(context).pop,
                                child: const Icon(Icons.close),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CommentPage(
                          useAppBar: false,
                          postId: post.id,
                        ),
                      )
                    ],
                  )),
              context: context,
            ),
      icon: const FaIcon(
        FontAwesomeIcons.comment,
      ),
    );
  }

  Widget _buildFavoriteButton(AuthenticationState authState) {
    return BlocBuilder<IsPostFavoritedBloc, AsyncLoadState<bool>>(
      builder: (context, state) => TextButton.icon(
        onPressed: () async {
          _onPressedWithLoadingToast(
            context: context,
            status: state.status,
            success: () async {
              final favBloc = context.read<IsPostFavoritedBloc>();
              if (authState is Unauthenticated) {
                showSimpleSnackBar(
                  context: context,
                  content: const Text(
                    'post.detail.login_required_notice',
                  ).tr(),
                  duration: const Duration(seconds: 1),
                );
              }

              final result = state.data!
                  ? RepositoryProvider.of<IFavoritePostRepository>(context)
                      .removeFromFavorites(post.id)
                  : RepositoryProvider.of<IFavoritePostRepository>(context)
                      .addToFavorites(post.id);

              await result;

              favBloc.add(IsPostFavoritedRequested(postId: post.id));
            },
          );
        },
        icon: state.status == LoadStatus.success && state.data!
            ? const FaIcon(
                FontAwesomeIcons.solidHeart,
                color: Colors.red,
              )
            : const FaIcon(
                FontAwesomeIcons.heart,
              ),
        label: Text(
          post.favCount.toString(),
          style: state.status == LoadStatus.success && state.data!
              ? const TextStyle(color: Colors.red)
              : null,
        ),
      ),
    );
  }
}

void _onPressed({
  required BuildContext context,
  required LoadStatus status,
  required void Function() success,
  required void Function() loading,
}) {
  if (status == LoadStatus.success) {
    success();
  } else if (status == LoadStatus.initial || status == LoadStatus.loading) {
    loading();
  }
}

void _onPressedWithLoadingToast({
  required BuildContext context,
  required LoadStatus status,
  required void Function() success,
}) =>
    _onPressed(
      context: context,
      status: status,
      success: success,
      loading: () => showSimpleSnackBar(
        context: context,
        content: const Text('Please wait...'),
      ),
    );

enum ShareMode {
  source,
  booru,
}

String getShareContent(ShareMode mode, Post post, String endpoint) {
  final booruLink = '${endpoint}posts/${post.id}';
  if (mode == ShareMode.booru) return booruLink;
  if (post.source.uri == null) return booruLink;

  return post.source.uri.toString();
}

class ModalShare extends StatelessWidget {
  const ModalShare({
    Key? key,
    required this.post,
    required this.endpoint,
    required this.onTap,
    required this.onTapFile,
    required this.imagePath,
  }) : super(key: key);

  final void Function(String value) onTap;
  final void Function(String filePath) onTapFile;
  final Post post;
  final String endpoint;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (post.source.uri != null)
            ListTile(
              title: const Text('post.detail.share.source').tr(),
              leading: const FaIcon(FontAwesomeIcons.link),
              onTap: () {
                Navigator.of(context).pop();
                onTap.call(getShareContent(ShareMode.source, post, endpoint));
              },
            ),
          ListTile(
            title: const Text('post.detail.share.booru').tr(),
            leading: const FaIcon(FontAwesomeIcons.box),
            onTap: () {
              Navigator.of(context).pop();
              onTap.call(getShareContent(ShareMode.booru, post, endpoint));
            },
          ),
          if (imagePath != null)
            ListTile(
              title: const Text('post.detail.share.image').tr(),
              leading: const FaIcon(FontAwesomeIcons.fileImage),
              onTap: () {
                Navigator.of(context).pop();
                onTapFile.call(imagePath!);
              },
            ),
        ],
      ),
    ));
  }
}
