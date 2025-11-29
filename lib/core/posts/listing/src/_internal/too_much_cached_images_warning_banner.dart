// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../../foundation/utils/file_utils.dart';
import '../../../../images/providers.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';

const _kHideImageCacheWarningKey = 'hide_image_cache_warning';

final _imageCachesProvider = FutureProvider<int>((ref) async {
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
    final cacheManager = ref.watch(defaultImageCacheManagerProvider);

    return ref
        .watch(_imageCachesProvider)
        .when(
          data: (cacheSize) {
            return PersistentDismissableInfoContainer(
              storageKey: _kHideImageCacheWarningKey,
              shouldShow: () => cacheSize > threshold,
              mainColor: Theme.of(context).colorScheme.primary,
              content: context.t.cache.image.reminder.description(
                size: Filesize.parse(cacheSize),
              ),
              dontShowAgainText: context.t.reminder.dont_show_again,
              actions: [
                FilledButton(
                  onPressed: () async {
                    final success = await clearImageCache(cacheManager);

                    final c = navigatorKey.currentState?.context;

                    if (c != null && c.mounted) {
                      if (success) {
                        showSuccessToast(
                          context,
                          context.t.cache.image.reminder.cleared,
                        );
                      } else {
                        showErrorToast(
                          context,
                          context.t.cache.image.reminder.failed,
                        );
                      }
                    }
                  },
                  child: Text(context.t.settings.performance.clear_cache),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
  }
}
