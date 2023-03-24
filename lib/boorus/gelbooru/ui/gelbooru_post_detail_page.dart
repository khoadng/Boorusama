// Flutter imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_post_slider.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/network_indicator_with_network_bloc.dart';

double getTopActionIconAlignValue() => hasStatusBar() ? -0.92 : -1;

class GelbooruPostDetailPage extends StatefulWidget {
  const GelbooruPostDetailPage({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  final int initialIndex;
  final List<Post> posts;

  @override
  State<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<GelbooruPostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        context.select((SliverPostGridBloc bloc) => bloc.state.currentIndex);

    return WillPopScope(
      onWillPop: () async {
        context
            .read<SliverPostGridBloc>()
            .add(SliverPostGridExited(lastIndex: currentIndex));

        return true;
      },
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NetworkUnavailableIndicatorWithNetworkBloc(
              includeSafeArea: false,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        GelbooruPostSlider(
                          posts: widget.posts,
                          imagePath: imagePath,
                          initialPage: widget.initialIndex,
                        ),
                        Align(
                          alignment: Alignment(
                            -0.75,
                            getTopActionIconAlignValue(),
                          ),
                          child: const _NavigationButtonGroup(),
                        ),
                        Align(
                          alignment: Alignment(
                            0.9,
                            getTopActionIconAlignValue(),
                          ),
                          child:
                              _TopRightButtonGroup(widget.posts[currentIndex]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButtonGroup extends StatelessWidget {
  const _NavigationButtonGroup();

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const _BackButton(),
          const SizedBox(
            width: 4,
          ),
          CircularIconButton(
            icon: theme == ThemeMode.light
                ? Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : const Icon(Icons.home),
            onPressed: () => goToHomePage(context),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    final currentIndex =
        context.select((SliverPostGridBloc bloc) => bloc.state.currentIndex);

    return CircularIconButton(
      icon: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: theme == ThemeMode.light
            ? Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : const Icon(Icons.arrow_back_ios),
      ),
      onPressed: () {
        context
            .read<SliverPostGridBloc>()
            .add(SliverPostGridExited(lastIndex: currentIndex));
        Navigator.of(context).pop();
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class MoreActionButton extends StatelessWidget {
  const MoreActionButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final endpoint = context.select(
      (CurrentBooruBloc bloc) => bloc.state.booru?.url ?? safebooru().url,
    );

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

class _TopRightButtonGroup extends StatelessWidget {
  const _TopRightButtonGroup(this.post);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: [
        MoreActionButton(
          post: post,
        ),
      ],
    );
  }
}
