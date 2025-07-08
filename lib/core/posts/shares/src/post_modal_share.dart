// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../foundation/path.dart';
import '../../../config_widgets/booru_logo.dart';
import '../../../config_widgets/website_logo.dart';
import '../../post/post.dart';
import '../../sources/source.dart';
import 'download_and_share.dart';

final _cachedImageFileProvider = FutureProvider.autoDispose
    .family<XFile?, ModalShareImageData>(
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

typedef ModalShareImageData = ({String? imageUrl, String? imageExt});

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
                title: Text(context.t.post.detail.share.source),
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
                title: Text(context.t.post.detail.share.booru),
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
            ref
                .watch(_cachedImageFileProvider(imageData()))
                .when(
                  data: (file) {
                    return file != null
                        ? ListTile(
                            title: Text(context.t.post.detail.share.image),
                            leading: const Icon(
                              Symbols.image,
                              fill: 1,
                            ),
                            subtitle: Text(
                              'Image quality will depend on the current selected booru profile.'
                                  .hc,
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
                  loading: () => ListTile(
                    title: Text('Loading image...'.hc),
                  ),
                  error: (error, stack) => ListTile(
                    title: Text('Failed to load image'.hc),
                  ),
                ),
            ListTile(
              title: Text('Download and share image'.hc),
              leading: const Icon(
                Symbols.download,
                fill: 1,
              ),
              subtitle: Text(
                'Download the original image and share it directly.'.hc,
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
