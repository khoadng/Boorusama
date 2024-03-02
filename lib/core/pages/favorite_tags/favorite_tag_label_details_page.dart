// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'favorite_tag_add_tag_to_label_button.dart';

class FavoriteTagLabelDetailsPage extends ConsumerWidget {
  const FavoriteTagLabelDetailsPage({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(favoriteTagsProvider);
    final filtered =
        tags.where((e) => e.labels?.contains(label) ?? false).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        actions: [
          FavoriteTagAddTagToLabelButton(label: label),
        ],
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final tag = filtered[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(tag.name),
            trailing: IconButton(
              onPressed: () {
                ref.read(favoriteTagsProvider.notifier).update(
                      tag.name,
                      tag.removeLabel(label),
                    );
              },
              icon: const Icon(Symbols.close),
            ),
          );
        },
      ),
    );
  }
}
