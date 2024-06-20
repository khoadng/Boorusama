// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class GeneralTagContextMenu extends ConsumerWidget {
  const GeneralTagContextMenu({
    super.key,
    this.itemBindings = const {},
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;
  final Map<String, void Function()> itemBindings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tag)).then((_) {
                showToast(
                  'post.detail.copied'.tr(),
                  position: ToastPosition.bottom,
                  textPadding: const EdgeInsets.all(8),
                );
              });
            },
          ),
          ContextMenuButtonConfig(
            'Search',
            onPressed: () {
              goToSearchPage(context, tag: tag);
            },
          ),
          ContextMenuButtonConfig(
            'post.detail.add_to_favorites'.tr(),
            onPressed: () {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            },
          ),
          ContextMenuButtonConfig(
            'Add to global blacklist',
            onPressed: () {
              globalNotifier.addTagWithToast(tag);
            },
          ),
          for (final entry in itemBindings.entries)
            ContextMenuButtonConfig(
              entry.key,
              onPressed: entry.value,
            ),
        ],
      ),
      child: child,
    );
  }
}
