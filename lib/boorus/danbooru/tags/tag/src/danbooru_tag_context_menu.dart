// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/tags/tag/widgets.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../blacklist/providers.dart';
import '../../../configs/providers.dart';
import '../../../saved_searches/saved_search/routes.dart';
import '../../../wikis/types.dart';

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
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return GeneralTagContextMenu(
      tag: tag,
      itemBindings: {
        context.t.post.detail.open_wiki: () => launchWikiPage(
          config.url,
          tag,
        ),
        if (loginDetails.hasLogin())
          context.t.tags.actions.add_to_blacklist: () => ref
              .read(danbooruBlacklistedTagsProvider(config).notifier)
              .addWithToast(context: context, tag: tag),
        if (loginDetails.hasLogin())
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
