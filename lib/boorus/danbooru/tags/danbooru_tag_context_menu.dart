// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/blacklist/blacklist.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/wikis/wikis.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruTagContextMenu extends ConsumerWidget {
  const DanbooruTagContextMenu({
    super.key,
    required this.tag,
    required this.child,
  });

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return GeneralTagContextMenu(
      tag: tag,
      itemBindings: {
        'post.detail.open_wiki'.tr(): () => launchWikiPage(
              config.url,
              tag,
            ),
        if (config.hasLoginDetails())
          'post.detail.add_to_blacklist'.tr(): () => ref
              .read(danbooruBlacklistedTagsProvider(config).notifier)
              .addWithToast(context: context, tag: tag),
        if (config.hasLoginDetails())
          'post.detail.copy_and_open_saved_search'.tr(): () async {
            await AppClipboard.copy(tag);

            if (context.mounted) {
              goToSavedSearchEditPage(context);
            }
          },
      },
      child: child,
    );
  }
}
