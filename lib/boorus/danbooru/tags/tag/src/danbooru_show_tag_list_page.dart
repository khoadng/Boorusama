// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/foundation/toast.dart';
import '../../../../../core/tags/favorites/providers.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../../../core/tags/tag/widgets.dart';
import '../../../../../core/wikis/launcher.dart';
import '../../../blacklist/providers.dart';

class DanbooruShowTagListPage extends ConsumerWidget {
  const DanbooruShowTagListPage({
    super.key,
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final blacklistNotifier =
        ref.watch(danbooruBlacklistedTagsProvider(config).notifier);
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);
    final favoriteNotifier = ref.watch(favoriteTagsProvider.notifier);

    return ShowTagListPage(
      tags: tags,
      onOpenWiki: (tag) {
        launchWikiPage(
          config.url,
          tag.rawName,
        );
      },
      onAddToBlacklist: config.hasLoginDetails()
          ? (tag) {
              blacklistNotifier.addWithToast(
                context: ref.context,
                tag: tag.rawName,
              );
            }
          : null,
      onAddToGlobalBlacklist: (tag) {
        globalNotifier.addTagWithToast(
          ref.context,
          tag.rawName,
        );
      },
      onAddToFavoriteTags: (tag) async {
        await favoriteNotifier.add(tag.rawName);

        if (!context.mounted) return;

        showSuccessToast(
          context,
          'Added',
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.surface,
          ),
        );
      },
    );
  }
}
