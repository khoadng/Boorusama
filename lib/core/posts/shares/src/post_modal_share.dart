// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../config_widgets/website_logo.dart';
import '../../../configs/config/types.dart';
import '../../../downloads/filename/types.dart';
import '../../details/providers.dart';
import '../../post/providers.dart';
import '../../post/types.dart';
import '../../sources/types.dart';
import 'download_and_share.dart';

final _cachedImageFileProvider = FutureProvider.autoDispose
    .family<XFile?, ModalShareImageData>(
      (ref, data) async {
        final imageUrl = data.imageUrl;
        final imageExt = data.imageExt;

        if (imageUrl == null) return null;

        final ext = urlExtension(imageUrl);
        final effectiveExt = ext.isNotEmpty ? ext : imageExt;

        final cacheManager = data.imageCacheManager;
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
  ImageCacheManager imageCacheManager,
});

class PostModalShare extends ConsumerWidget {
  const PostModalShare({
    required this.post,
    required this.auth,
    required this.viewer,
    required this.download,
    required this.filenameBuilder,
    required this.imageCacheManager,
    super.key,
  });

  final Post post;
  final BooruConfigAuth auth;
  final BooruConfigViewer viewer;
  final BooruConfigDownload download;
  final DownloadFilenameGenerator? filenameBuilder;
  final ImageCacheManager imageCacheManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaUrlResolver = ref.watch(
      mediaUrlResolverProvider(auth),
    );
    final imageData = (
      imageUrl: mediaUrlResolver.resolveMediaUrl(post, viewer),
      imageExt: post.format,
      imageCacheManager: imageCacheManager,
    );

    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(auth));
    final booruLink = postLinkGenerator.getLink(post);
    final sourceLink = post.source;

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
                leading: ConfigAwareWebsiteLogo(url: s.url),
                onTap: () {
                  Navigator.of(context).pop();
                  SharePlus.instance.share(ShareParams(uri: s.uri));
                },
              ),
              _ => const SizedBox.shrink(),
            },
            if (booruLink.isNotEmpty)
              if (Uri.tryParse(booruLink) case final Uri uri)
                ListTile(
                  title: Text(context.t.post.detail.share.booru),
                  subtitle: Text(booruLink),
                  leading: ConfigAwareWebsiteLogo(url: booruLink),
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
                .watch(_cachedImageFileProvider(imageData))
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
                  builder: (context) => DownloadAndShareDialog(
                    post: post,
                    auth: auth,
                    download: download,
                    filenameBuilder: filenameBuilder,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
