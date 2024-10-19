// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/blacklist/blacklist.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/widgets/import_export_tag_button.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruBlacklistedTagsPage extends ConsumerWidget {
  const DanbooruBlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tags = ref.watch(danbooruBlacklistedTagsProvider(config));

    return BlacklistedTagsViewScaffold(
      title: 'blacklisted_tags.blacklisted_tags'.tr(),
      actions: [
        if (tags != null)
          ImportExportTagButton(
            tags: tags,
            onImport: (tagString) => ref
                .read(danbooruBlacklistedTagsProvider(config).notifier)
                .addFromStringWithToast(
                  context: context,
                  tagString: tagString,
                ),
          )
        else
          const SizedBox.shrink(),
      ],
      tags: tags,
      onAddTag: (tag) {
        ref
            .read(danbooruBlacklistedTagsProvider(ref.readConfig).notifier)
            .addWithToast(
              context: context,
              tag: tag,
            );
      },
      onEditTap: (oldTag, newTag) {
        ref
            .read(danbooruBlacklistedTagsProvider(ref.readConfig).notifier)
            .replace(
              oldTag: oldTag,
              newTag: newTag,
            );
      },
      onRemoveTag: (tag) {
        ref
            .read(danbooruBlacklistedTagsProvider(ref.readConfig).notifier)
            .removeWithToast(
              context: context,
              tag: tag,
            );
      },
    );
  }
}
