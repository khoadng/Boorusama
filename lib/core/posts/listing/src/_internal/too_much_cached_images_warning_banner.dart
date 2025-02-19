// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../cache/providers.dart';
import '../../../../foundation/toast.dart';
import '../../../../router.dart';
import '../../../../utils/file_utils.dart';
import '../../../../widgets/widgets.dart';

// Only need check once at the start
final _cacheImageActionsPerformedProvider = StateProvider<bool>((ref) => false);

const _kHideImageCacheWarningKey = 'hide_image_cache_warning';

final _imageCachesProvider = FutureProvider<int>((ref) async {
  final miscData = ref.watch(miscDataBoxProvider);
  final hideWarning = miscData.get(_kHideImageCacheWarningKey) == 'true';

  if (hideWarning) return -1;

  final imageCacheSize = await getImageCacheSize();

  return imageCacheSize.size;
});

class TooMuchCachedImagesWarningBanner extends ConsumerWidget {
  const TooMuchCachedImagesWarningBanner({
    required this.threshold,
    super.key,
  });

  final int threshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performed = ref.watch(_cacheImageActionsPerformedProvider);

    if (performed) return const SizedBox.shrink();

    return ref.watch(_imageCachesProvider).when(
          data: (cacheSize) {
            if (cacheSize > threshold) {
              final miscData = ref.watch(miscDataBoxProvider);

              return DismissableInfoContainer(
                mainColor: Theme.of(context).colorScheme.primary,
                content:
                    'The app has stored <b>${Filesize.parse(cacheSize)}</b> worth of images. Would you like to clear it to free up some space?',
                actions: [
                  FilledButton(
                    onPressed: () async {
                      ref
                          .read(_cacheImageActionsPerformedProvider.notifier)
                          .state = true;
                      final success = await clearImageCache();

                      final c = navigatorKey.currentState?.context;

                      if (c != null && c.mounted) {
                        if (success) {
                          showSuccessToast(context, 'Cache cleared');
                        } else {
                          showErrorToast(context, 'Failed to clear cache');
                        }
                      }
                    },
                    child: const Text('settings.performance.clear_cache').tr(),
                  ),
                  TextButton(
                    onPressed: () {
                      miscData.put(_kHideImageCacheWarningKey, 'true');
                      ref
                          .read(_cacheImageActionsPerformedProvider.notifier)
                          .state = true;
                    },
                    child: const Text("Don't show again"),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
  }
}
