// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/utils.dart';

class DanbooruMoreActionButton extends StatelessWidget {
  const DanbooruMoreActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final post =
        context.select((PostDetailBloc bloc) => bloc.state.currentPost);
    final endpoint = context.select(
      (CurrentBooruBloc bloc) => bloc.state.booru?.url ?? safebooru().url,
    );
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    final booru = context.select((CurrentBooruBloc bloc) => bloc.state.booru);

    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
        width: 40,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          shape: const CircleBorder(),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'download':
                  download(post);
                  break;
                case 'add_to_bookmark':
                  context.read<BookmarkCubit>().addBookmark(
                        post.sampleImageUrl,
                        booru!,
                        post,
                      );
                  break;
                case 'add_to_favgroup':
                  goToAddToFavoriteGroupSelectionPage(context, [post]);
                  break;
                case 'add_to_blacklist':
                  goToAddToBlacklistPage(context, post);
                  break;
                case 'view_in_browser':
                  launchExternalUrl(
                    post.getUriLink(endpoint),
                  );
                  break;
                case 'view_original':
                  goToOriginalImagePage(context, post);
                  break;
                // ignore: no_default_cases
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: const Text('download.download').tr(),
              ),
              const PopupMenuItem(
                value: 'add_to_bookmark',
                child: Text('Add to Bookmark'),
              ),
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_favgroup',
                  child: Text('Add to favorite group'),
                ),
              if (authenticationState is Authenticated)
                const PopupMenuItem(
                  value: 'add_to_blacklist',
                  child: Text('Add to blacklist'),
                ),
              PopupMenuItem(
                value: 'view_in_browser',
                child: const Text('post.detail.view_in_browser').tr(),
              ),
              if (!post.isVideo)
                PopupMenuItem(
                  value: 'view_original',
                  child: const Text('post.image_fullview.view_original').tr(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
