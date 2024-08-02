// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/widgets/widgets.dart';

final _cachedImageFileProvider =
    FutureProvider.autoDispose.family<XFile?, ModelShareImageData>(
  (ref, data) async {
    final imageUrl = data.imageUrl;
    final imageExt = data.imageExt;

    if (imageUrl == null) return null;

    final ext = extension(imageUrl);
    final effectiveExt = ext.isNotEmpty ? ext : imageExt;
    final file = await getCachedImageFile(imageUrl);

    if (file == null || effectiveExt == null) return null;

    // attach the extension to the file
    final newPath = file.path + effectiveExt;
    final newFile = file.copySync(newPath);
    final xFile = XFile(newFile.path);

    return xFile;
  },
);

typedef ModelShareImageData = ({
  String? imageUrl,
  String? imageExt,
});

class PostModalShare extends ConsumerWidget {
  const PostModalShare({
    super.key,
    required this.booruLink,
    required this.sourceLink,
    required this.imageData,
  });

  final String booruLink;
  final PostSource sourceLink;
  final ModelShareImageData Function() imageData;

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
            ref.watch(_cachedImageFileProvider(imageData())).when(
                  data: (file) {
                    return file != null
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
                                [file],
                                subject: file.name,
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
