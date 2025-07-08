// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/blacklists/widgets.dart';
import '../../../../core/configs/ref.dart';
import '../../../../core/widgets/import_export_tag_button.dart';
import 'providers/blacklisted_tags_notifier.dart';
import 'providers/blacklisted_tags_notifier_toast.dart';

class DanbooruBlacklistedTagsPage extends ConsumerWidget {
  const DanbooruBlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(
      danbooruBlacklistedTagsProvider(config).notifier,
    );

    return ref
        .watch(danbooruBlacklistedTagsProvider(config))
        .when(
          data: (tags) {
            return BlacklistedTagsViewScaffold(
              title: context.t.blacklisted_tags.blacklisted_tags,
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
          error: (e, _) => Scaffold(
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
