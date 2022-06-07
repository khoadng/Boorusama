// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/is_post_favorited.dart';
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
    useEffect(() {
      ReadContext(context)
          .read<IsPostFavoritedCubit>()
          .checkIfFavorited(post.id);
    }, []);

    final favCount = useState(post.favCount);

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) =>
          ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
        BlocBuilder<IsPostFavoritedCubit, AsyncLoadState<bool>>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              return TextButton.icon(
                  onPressed: () async {
                    if (authState is Unauthenticated) {
                      final snackbar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                        elevation: 6.0,
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
                        .read<IsPostFavoritedCubit>()
                        .checkIfFavorited(post.id);
                    print("operation success = $success");
                  },
                  icon: state.data!
                      ? FaIcon(FontAwesomeIcons.solidHeart, color: Colors.red)
                      : FaIcon(
                          FontAwesomeIcons.heart,
                          color: Colors.white,
                        ),
                  label: Text(
                    favCount.value.toString(),
                    style: TextStyle(color: Colors.white),
                  ));
            } else if (state.status == LoadStatus.failure) {
              return SizedBox.shrink();
            } else {
              return Center(
                child: TextButton.icon(
                    onPressed: null,
                    icon: FaIcon(
                      FontAwesomeIcons.spinner,
                      color: Colors.white,
                    ),
                    label: Text(
                      post.favCount.toString(),
                      style: TextStyle(color: Colors.white),
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
          icon: FaIcon(
            FontAwesomeIcons.comment,
            color: Colors.white,
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
                  onTap: (value) => Share.share(value),
                  onTapFile: (filePath) => Share.shareFiles([filePath]),
                  post: post,
                  imagePath: imagePath,
                );
              },
            ),
          ),
          icon: FaIcon(
            FontAwesomeIcons.shareFromSquare,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () => context.read<IDownloadService>().download(post),
          icon: FaIcon(
            FontAwesomeIcons.download,
            color: Colors.white,
          ),
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
  final booruLink = "${endpoint}posts/${post.id}";
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
              title: Text('Share source link'),
              leading: FaIcon(FontAwesomeIcons.link),
              onTap: () {
                Navigator.of(context).pop();
                onTap.call(getShareContent(ShareMode.source, post, endpoint));
              },
            ),
          ListTile(
            title: Text('Share booru link'),
            leading: FaIcon(FontAwesomeIcons.box),
            onTap: () {
              Navigator.of(context).pop();
              onTap.call(getShareContent(ShareMode.booru, post, endpoint));
            },
          ),
          if (imagePath != null)
            ListTile(
              title: Text('Share image'),
              leading: FaIcon(FontAwesomeIcons.fileImage),
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
