// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/flutter.dart';

class FavoriteTagAddTagToLabelButton extends ConsumerWidget {
  const FavoriteTagAddTagToLabelButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        goToQuickSearchPage(
          context,
          ref: ref,
          onSubmitted: (context, text) {
            context.navigator.pop();
            ref.read(favoriteTagsProvider.notifier).add(
              text,
              labels: [
                label,
              ],
            );
          },
          onSelected: (tag) {
            ref.read(favoriteTagsProvider.notifier).add(
              tag.value,
              labels: [
                label,
              ],
            );
          },
        );
      },
      icon: const Icon(Symbols.add),
    );
  }
}
