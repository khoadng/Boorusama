// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../favgroups/providers.dart';
import '../../../favgroups/types.dart';

class FavoriteGroupDeleteConfirmationDialog extends ConsumerWidget {
  const FavoriteGroupDeleteConfirmationDialog({
    required this.favGroup,
    super.key,
  });

  final DanbooruFavoriteGroup favGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return AlertDialog(
      content: Text(context.t.favorite_groups.detete_confirmation),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.generic.action.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref
                .read(danbooruFavoriteGroupsProvider(config).notifier)
                .delete(group: favGroup);
          },
          child: Text(context.t.generic.action.ok),
        ),
      ],
    );
  }
}
