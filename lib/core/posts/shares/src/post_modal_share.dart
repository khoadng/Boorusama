// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../config_widgets/booru_logo.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../foundation/path.dart';
import '../../post/post.dart';
import '../../sources/source.dart';
import 'download_and_share.dart';

final _cachedImageFileProvider =
    FutureProvider.autoDispose.family<XFile?, ModalShareImageData>(
  (ref, data) async {
    final imageUrl = data.imageUrl;
    final imageExt = data.imageExt;

    if (imageUrl == null) return null;

    final ext = extension(imageUrl);
    final effectiveExt = ext.isNotEmpty ? ext : imageExt;

    final cacheManager = DefaultImageCacheManager();
    final cacheKey = cacheManager.generateCacheKey(imageUrl);
    final file = await cacheManager.getCachedFile(cacheKey);

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
    required this.booruLink,
    required this.sourceLink,
    required this.imageData,
    required this.post,
    super.key,
  });

  final String booruLink;
  final PostSource sourceLink;
  final ModalShareImageData Function() imageData;
  final Post post;

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
                  leading: ConfigAwareWebsiteLogo(url: s.faviconUrl),
                  onTap: () {
                    Navigator.of(context).pop();
                    SharePlus.instance.share(ShareParams(uri: s.uri));
                  },
                ),
              _ => const SizedBox.shrink(),
            },
            if (Uri.tryParse(booruLink) case final Uri uri)
              ListTile(
                title: const Text('post.detail.share.booru').tr(),
                subtitle: Text(booruLink),
                leading: BooruLogo(source: booruLink),
                onTap: () {
                  Navigator.of(context).pop();
                  SharePlus.instance.share(
                    ShareParams(
                      uri: uri,
                      subject: booruLink,
                    ),
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

                              SharePlus.instance.share(
                                ShareParams(
                                  files: [file],
                                  subject: file.name,
                                ),
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
            ListTile(
              title: const Text('Download and share image'),
              leading: const Icon(
                Symbols.download,
                fill: 1,
              ),
              subtitle: const Text(
                'Download the original image and share it directly.',
              ),
              onTap: () {
                Navigator.of(context).pop();

                showDialog(
                  context: context,
                  builder: (context) => DownloadAndShareDialog(post: post),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
