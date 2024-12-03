// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
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
    final artistTags = [...post.artistTags]..remove('banned_artist');

    return SliverPostGridImageGridItem(
      post: post,
      hideOverlay: hideOverlay,
      quickActionButton: !post.isBanned && enableFav
          ? DefaultImagePreviewQuickActionButton(post: post)
          : null,
      autoScrollOptions: autoScrollOptions,
      onTap: post.isBanned ? null : onTap,
      image: image,
      score: post.isBanned ? null : post.score,
      blockOverlay: post.isBanned
          ? BlockOverlayItem(
              overlay: Column(
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
                          final WebSource source =>
                            WebsiteLogo(url: source.faviconUrl),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        maxLines: 1,
                        'Banned post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (artistTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Wrap(
                        children: [
                          for (final tag in artistTags)
                            ActionChip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                tag.replaceAll('_', ' '),
                                maxLines: 1,
                                style: TextStyle(
                                  color: context.colorScheme.onErrorContainer,
                                ),
                              ),
                              backgroundColor:
                                  context.colorScheme.errorContainer,
                              onPressed: () {
                                AppClipboard.copyAndToast(
                                  context,
                                  artistTags.join(' '),
                                  message: 'Tag copied to clipboard',
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              onTap: switch (post.source) {
                final WebSource source => () =>
                    launchExternalUrlString(source.url),
                _ => null,
              },
            )
          : null,
    );
  }
}
