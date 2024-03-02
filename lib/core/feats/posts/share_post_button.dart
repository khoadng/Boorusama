// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      splashRadius: 16,
      onPressed: () => ref.sharePost(
        post,
        context: context,
        state: ref.watch(postShareProvider(post)),
      ),
      icon: const Icon(
        Symbols.share,
      ),
    );
  }
}

extension PostShareX on WidgetRef {
  void sharePost(
    Post post, {
    required BuildContext context,
    required PostShareState state,
  }) {
    Screen.of(context).size == ScreenSize.small
        ? showMaterialModalBottomSheet(
            expand: false,
            context: context,
            barrierColor: Colors.black45,
            backgroundColor: Colors.transparent,
            builder: (context) => ModalShare(
              booruLink: state.booruLink,
              sourceLink: state.sourceLink,
              imageUrl: () => defaultPostImageUrlBuilder(this)(post),
            ),
          )
        : showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: ModalShare(
                booruLink: state.booruLink,
                sourceLink: state.sourceLink,
                imageUrl: () => defaultPostImageUrlBuilder(this)(post),
              ),
            ),
          );
  }
}

final _cachedImagePathProvider =
    FutureProvider.autoDispose.family<String, String>(
  (ref, imageUrl) async {
    final path = await getCachedImageFilePath(imageUrl);

    return path ?? '';
  },
);

class ModalShare extends ConsumerWidget {
  const ModalShare({
    super.key,
    required this.booruLink,
    required this.sourceLink,
    required this.imageUrl,
  });

  final String booruLink;
  final PostSource sourceLink;
  final String Function() imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (sourceLink) {
              WebSource s => ListTile(
                  title: const Text('post.detail.share.source').tr(),
                  subtitle: Text(s.uri.toString()),
                  leading: WebsiteLogo(url: s.faviconUrl),
                  onTap: () {
                    context.navigator.pop();
                    Share.share(s.uri.toString());
                  },
                ),
              _ => const SizedBox.shrink(),
            },
            ListTile(
              title: const Text('post.detail.share.booru').tr(),
              subtitle: Text(booruLink),
              leading: PostSource.from(booruLink).whenWeb(
                (source) => BooruLogo(source: source),
                () => const Icon(Symbols.box),
              ),
              onTap: () {
                context.navigator.pop();
                Share.share(
                  booruLink,
                  subject: booruLink,
                );
              },
            ),
            ref.watch(_cachedImagePathProvider(imageUrl())).when(
                  data: (imagePath) {
                    return imagePath.isNotEmpty
                        ? ListTile(
                            title: const Text('post.detail.share.image').tr(),
                            leading: const Icon(
                              Symbols.image,
                              fill: 1,
                            ),
                            subtitle: const Text(
                                'Image quality will depend on the current selected booru profile.'),
                            onTap: () {
                              context.navigator.pop();
                              Share.shareXFiles(
                                [
                                  XFile(imagePath),
                                ],
                                subject: basename(imagePath),
                              );
                            },
                          )
                        : const SizedBox.shrink();
                  },
                  loading: () => const ListTile(
                    title: Text('Loading image...'),
                  ),
                  error: (error, stack) => const ListTile(
                    title: Text('Failed to load image'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
