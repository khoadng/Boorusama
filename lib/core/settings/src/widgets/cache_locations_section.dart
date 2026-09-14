// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/cache_documents.dart';
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/filesystem.dart';
import '../../../../foundation/path.dart';
import '../../../../foundation/platform.dart';
import '../../../../foundation/url_launcher.dart';

final _cacheRootProvider = FutureProvider.autoDispose<String>((ref) async {
  final path = await ref.watch(appFileSystemProvider).getTemporaryPath();
  if (path == null) throw StateError('Cache directory not available');
  return path;
});

class CacheLocationsSection extends ConsumerStatefulWidget {
  const CacheLocationsSection({super.key});

  @override
  ConsumerState<CacheLocationsSection> createState() =>
      _CacheLocationsSectionState();
}

class _CacheLocationsSectionState extends ConsumerState<CacheLocationsSection> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final storage = context.t.settings.data_and_storage;
    final labels = storage.cache_locations;

    return KurumiSettingsCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(labels.title),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            ref
                .watch(_cacheRootProvider)
                .when(
                  data: (root) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1),
                      _CacheLocation(
                        title: storage.image_only_cache,
                        path: join(root, cacheImageFolderName),
                        kind: CacheDocumentKind.images,
                      ),
                      const Divider(height: 1),
                      _CacheLocation(
                        title: storage.video_cache,
                        path: join(root, VideoCacheManager.defaultSubPath),
                        kind: CacheDocumentKind.videos,
                      ),
                      if (ref.watch(appPlatformProvider).isIOS) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          subtitle: Text(labels.private_storage),
                        ),
                      ],
                    ],
                  ),
                  loading: () => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    subtitle: Text(storage.loading),
                  ),
                  error: (_, _) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    subtitle: Text(storage.error_loading_cache_info),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CacheLocation extends ConsumerWidget {
  const _CacheLocation({
    required this.title,
    required this.path,
    required this.kind,
  });

  final String title;
  final String path;
  final CacheDocumentKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = context.t.settings.data_and_storage.cache_locations;
    final platform = ref.watch(appPlatformProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title),
      trailing: IconButton(
        tooltip: context.t.generic.action.copy_path,
        icon: const Icon(Icons.copy),
        onPressed: () => AppClipboard.copyAndToast(
          context,
          path,
          message: context.t.generic.copied,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(path),
          if (platform.isAndroid || platform.isDesktop)
            TextButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(labels.open_folder),
              onPressed: () async {
                try {
                  if (platform.isAndroid) {
                    await CacheDocuments.open(
                      kind,
                      imagesLabel:
                          context.t.settings.data_and_storage.image_only_cache,
                      videosLabel:
                          context.t.settings.data_and_storage.video_cache,
                    );
                    return;
                  }
                  final exists = await ref
                      .read(appFileSystemProvider)
                      .directoryExists(path);
                  if (!exists) {
                    throw StateError('Cache folder does not exist');
                  }
                  final opened = await launchExternalUrl(
                    Uri.directory(
                      path,
                      windows: platform == AppPlatform.windows,
                    ),
                    launcher: ref.read(externalUrlLauncherProvider),
                  );
                  if (!opened) throw StateError('Could not open cache folder');
                } catch (_) {
                  if (context.mounted) {
                    Kurumi.showErrorToast(
                      context,
                      context.t.generic.errors.unknown,
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}
