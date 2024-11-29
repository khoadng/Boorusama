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
    final config = ref.watchConfigAuth;
    final notifier =
        ref.watch(danbooruBlacklistedTagsProvider(config).notifier);

    return ref.watch(danbooruBlacklistedTagsProvider(config)).when(
          data: (tags) {
            return BlacklistedTagsViewScaffold(
              title: 'blacklisted_tags.blacklisted_tags'.tr(),
              actions: [
                if (tags != null)
                  ImportExportTagButton(
                    tags: tags,
                    onImport: (tagString) => notifier.addFromStringWithToast(
                      context: context,
                      tagString: tagString,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
              tags: tags,
              onAddTag: (tag) {
                notifier.addWithToast(
                  context: context,
                  tag: tag,
                );
              },
              onEditTap: (oldTag, newTag) {
                notifier.replace(
                  oldTag: oldTag,
                  newTag: newTag,
                );
              },
              onRemoveTag: (tag) {
                notifier.removeWithToast(
                  context: context,
                  tag: tag,
                );
              },
            );
          },
          error: (e, __) => Scaffold(
            body: Center(
              child: Text('Error: $e'),
            ),
          ),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}
