// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import '../../../favgroups/favgroup.dart';
import '../../../favgroups/providers.dart';

class FavoriteGroupDeleteConfirmationDialog extends ConsumerWidget {
  const FavoriteGroupDeleteConfirmationDialog({
    super.key,
    required this.favGroup,
  });

  final DanbooruFavoriteGroup favGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return AlertDialog(
      content: const Text('favorite_groups.detete_confirmation').tr(),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('generic.action.cancel').tr(),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(danbooruFavoriteGroupsProvider(config).notifier)
                .delete(group: favGroup);
          },
          child: const Text('generic.action.ok').tr(),
        ),
      ],
    );
  }
}
