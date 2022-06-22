// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';

class PostActionToolbar extends HookWidget {
  const PostActionToolbar({
    Key? key,
    required this.post,
    required this.imagePath,
  }) : super(key: key);

  final Post post;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final favCount = useState(post.favCount);

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) =>
          ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
        BlocBuilder<IsPostFavoritedBloc, AsyncLoadState<bool>>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              return TextButton.icon(
                  onPressed: () async {
                    if (authState is Unauthenticated) {
                      const snackbar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                        elevation: 6,
                        content: Text(
                          'You have to log in to perform this action',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      return;
                    }

                    final result = state.data!
                        ? RepositoryProvider.of<IFavoritePostRepository>(
                                context)
                            .removeFromFavorites(post.id)
                        : RepositoryProvider.of<IFavoritePostRepository>(
                                context)
                            .addToFavorites(post.id);

                    final success = await result;
                    ReadContext(context)
                        .read<IsPostFavoritedBloc>()
                        .add(IsPostFavoritedRequested(postId: post.id));
                    // ignore: avoid_print
                    print('operation success = $success');
                  },
                  icon: state.data!
                      ? const FaIcon(FontAwesomeIcons.solidHeart,
                          color: Colors.red)
                      : const FaIcon(
                          FontAwesomeIcons.heart,
                        ),
                  label: Text(
                    favCount.value.toString(),
                    style:
                        state.data! ? const TextStyle(color: Colors.red) : null,
                  ));
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
                      post.favCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    )),
              );
            }
          },
        ),
        IconButton(
          onPressed: () => showBarModalBottomSheet(
            expand: false,
            context: context,
            builder: (context) => CommentPage(
              postId: post.id,
            ),
          ),
          icon: const FaIcon(
            FontAwesomeIcons.comment,
          ),
        ),
        IconButton(
          onPressed: () => showMaterialModalBottomSheet(
            expand: false,
            context: context,
            barrierColor: Colors.black45,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
              builder: (context, state) {
                return ModalShare(
                  endpoint: state.booru.url,
                  onTap: Share.share,
                  onTapFile: (filePath) => Share.shareFiles([filePath]),
                  post: post,
                  imagePath: imagePath,
                );
              },
            ),
          ),
          icon: const FaIcon(
            FontAwesomeIcons.shareFromSquare,
          ),
        ),
        BlocSelector<SettingsCubit, SettingsState, String?>(
          selector: (state) => state.settings.downloadPath,
          builder: (context, downloadPath) {
            return IconButton(
              onPressed: () => context.read<IDownloadService>().download(
                    post,
                    path: downloadPath,
                  ),
              icon: const FaIcon(
                FontAwesomeIcons.download,
              ),
            );
          },
        )
      ]),
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
              title: const Text('Share source link'),
              leading: const FaIcon(FontAwesomeIcons.link),
              onTap: () {
                Navigator.of(context).pop();
                onTap.call(getShareContent(ShareMode.source, post, endpoint));
              },
            ),
          ListTile(
            title: const Text('Share booru link'),
            leading: const FaIcon(FontAwesomeIcons.box),
            onTap: () {
              Navigator.of(context).pop();
              onTap.call(getShareContent(ShareMode.booru, post, endpoint));
            },
          ),
          if (imagePath != null)
            ListTile(
              title: const Text('Share image'),
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
