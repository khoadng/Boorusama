// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:side_sheet/side_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';

class PostActionToolbar extends StatefulWidget {
  const PostActionToolbar({
    Key? key,
    required this.post,
    required this.imagePath,
  }) : super(key: key);

  final Post post;
  final String? imagePath;

  @override
  State<PostActionToolbar> createState() => _PostActionToolbarState();
}

class _PostActionToolbarState extends State<PostActionToolbar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) => ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFavoriteButton(authState),
          _buildCommentButton(),
          _buildDownloadButton(),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return DownloadProviderWidget(
      builder: (context, download) => IconButton(
        onPressed: () => download(widget.post),
        icon: const FaIcon(FontAwesomeIcons.download),
      ),
    );
  }

  Widget _buildShareButton() {
    final modal = BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
      builder: (context, state) {
        return ModalShare(
          endpoint: state.booru.url,
          onTap: Share.share,
          onTapFile: (filePath) => Share.shareFiles([filePath]),
          post: widget.post,
          imagePath: widget.imagePath,
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

  Widget _buildCommentButton() {
    return IconButton(
      onPressed: () => Screen.of(context).size == ScreenSize.small
          ? showBarModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => CommentPage(
                postId: widget.post.id,
              ),
            )
          : SideSheet.right(
              width: 350,
              body: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    Expanded(
                      child: CommentPage(
                        useAppBar: false,
                        postId: widget.post.id,
                      ),
                    ),
                  ],
                ),
              ),
              context: context),
      icon: const FaIcon(
        FontAwesomeIcons.comment,
      ),
    );
  }

  Widget _buildFavoriteButton(AuthenticationState authState) {
    return BlocBuilder<IsPostFavoritedBloc, AsyncLoadState<bool>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          return TextButton.icon(
            onPressed: () async {
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
                      .removeFromFavorites(widget.post.id)
                  : RepositoryProvider.of<IFavoritePostRepository>(context)
                      .addToFavorites(widget.post.id);

              await result;

              favBloc.add(IsPostFavoritedRequested(postId: widget.post.id));
            },
            icon: state.data!
                ? const FaIcon(
                    FontAwesomeIcons.solidHeart,
                    color: Colors.red,
                  )
                : const FaIcon(
                    FontAwesomeIcons.heart,
                  ),
            label: Text(
              widget.post.favCount.toString(),
              style: state.data! ? const TextStyle(color: Colors.red) : null,
            ),
          );
        } else if (state.status == LoadStatus.failure) {
          return const SizedBox.shrink();
        } else {
          return Center(
            child: TextButton.icon(
              onPressed: null,
              icon: const FaIcon(
                FontAwesomeIcons.spinner,
              ),
              label: Text(
                widget.post.favCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
    );
  }
}

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
