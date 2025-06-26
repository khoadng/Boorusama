// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../blacklists/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../providers/blacklist_configs_notifier.dart';
import '../types/utils.dart';

class BlacklistConfigsEditPage extends ConsumerWidget {
  const BlacklistConfigsEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final tags = queryAsList(
      ref.watch(
        editBooruConfigProvider(id)
            .select((value) => value.blacklistConfigsTyped?.blacklistedTags),
      ),
    );
    final notifier = ref.watch(blacklistConfigsProvider(id).notifier);

    return BlacklistedTagsViewScaffold(
      tags: tags,
      onRemoveTag: (tag) {
        notifier.removeTag(tag);
      },
      onEditTap: (oldTag, newTag) {
        notifier.editTag(oldTag, newTag);
      },
      onAddTag: (tag) {
        notifier.addTag(tag);
      },
      title: 'Blacklist',
      actions: const [],
    );
  }
}
