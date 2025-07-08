// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/tags/tag/widgets.dart';
import '../../../../../core/wikis/launcher.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../blacklist/providers.dart';
import '../../../saved_searches/saved_search/routes.dart';

class DanbooruTagContextMenu extends ConsumerWidget {
  const DanbooruTagContextMenu({
    required this.tag,
    required this.child,
    super.key,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return GeneralTagContextMenu(
      tag: tag,
      itemBindings: {
        context.t.post.detail.open_wiki: () => launchWikiPage(
          config.url,
          tag,
        ),
        if (config.hasLoginDetails())
          context.t.post.detail.add_to_blacklist: () => ref
              .read(danbooruBlacklistedTagsProvider(config).notifier)
              .addWithToast(context: context, tag: tag),
        if (config.hasLoginDetails())
          context.t.post.detail.copy_and_open_saved_search: () async {
            await AppClipboard.copy(tag);

            if (context.mounted) {
              goToSavedSearchEditPage(ref);
            }
          },
      },
      child: child,
    );
  }
}
