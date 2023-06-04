// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruImageGridItem extends ConsumerWidget {
  const DanbooruImageGridItem({
    super.key,
    required this.post,
    required this.hideOverlay,
    required this.autoScrollOptions,
    required this.enableFav,
    this.onTap,
    required this.image,
  });

  final DanbooruPost post;
  final bool hideOverlay;
  final AutoScrollOptions autoScrollOptions;
  final VoidCallback? onTap;
  final bool enableFav;
  final Widget image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFaved =
        post.isBanned ? false : ref.watch(danbooruFavoriteProvider(post.id));
    final artistTags = post.artistTags..remove('banned_artist');
    final settings = ref.watch(settingsProvider);

    return ConditionalParentWidget(
      condition: post.isBanned,
      conditionalBuilder: (child) => Stack(
        children: [
          child,
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: switch (post.source) {
                          WebSource source =>
                            WebsiteLogo(url: source.faviconUrl),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                      const SizedBox(width: 4),
                      const AutoSizeText(
                        maxLines: 1,
                        'Banned artist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      children: [
                        for (final tag in artistTags)
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            label: AutoSizeText(
                              tag.removeUnderscoreWithSpace(),
                              minFontSize: 6,
                              maxLines: 1,
                            ),
                            backgroundColor: Colors.redAccent,
                            onPressed: () => switch (post.source) {
                              WebSource source =>
                                launchExternalUrlString(source.url),
                              _ => null,
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: ImageGridItem(
        hideOverlay: hideOverlay,
        isFaved: isFaved,
        enableFav: !post.isBanned && enableFav,
        onFavToggle: (isFaved) async {
          if (!isFaved) {
            ref.danbooruFavorites.remove(post.id);
          } else {
            ref.danbooruFavorites.add(post.id);
          }
        },
        autoScrollOptions: autoScrollOptions,
        onTap: post.isBanned
            ? () {
                Clipboard.setData(ClipboardData(text: artistTags.join(' ')))
                    .then((value) => showToast(
                          'Tag copied to clipboard',
                          position: ToastPosition.bottom,
                        ));
              }
            : onTap,
        image: image,
        isAnimated: post.isAnimated,
        isTranslated: post.isTranslated,
        hasComments: post.hasComment,
        hasParentOrChildren: post.hasParentOrChildren,
        hasSound: post.hasSound,
        duration: post.duration,
        score: post.isBanned
            ? null
            : settings.showScoresInGrid
                ? post.score
                : null,
      ),
    );
  }
}
