// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../foundation/path.dart';
import '../../sources/source.dart';

final _cachedImageFileProvider =
    FutureProvider.autoDispose.family<XFile?, ModalShareImageData>(
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

typedef ModalShareImageData = ({
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
  final ModalShareImageData Function() imageData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (sourceLink) {
              final WebSource s => ListTile(
                  title: const Text('post.detail.share.source').tr(),
                  subtitle: Text(s.uri.toString()),
                  leading: WebsiteLogo(url: s.faviconUrl),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(s.uri.toString());
                  },
                ),
              _ => const SizedBox.shrink(),
            },
            ListTile(
              title: const Text('post.detail.share.booru').tr(),
              subtitle: Text(booruLink),
              leading: BooruLogo(source: booruLink),
              onTap: () {
                Navigator.of(context).pop();
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
                              'Image quality will depend on the current selected booru profile.',
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
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
