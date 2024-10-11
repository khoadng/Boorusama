// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/widgets/widgets.dart';

class DefaultMultiSelectionActions<T extends Post> extends ConsumerWidget {
  const DefaultMultiSelectionActions({
    super.key,
    required this.controller,
    this.extraActions,
  });

  final MultiSelectController<T> controller;
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.selectedItemsNotifier,
      builder: (context, selectedPosts, child) {
        return MultiSelectionActionBar(
          children: [
            IconButton(
              onPressed: selectedPosts.isNotEmpty
                  ? () {
                      ref.bulkDownload(selectedPosts);

                      controller.disableMultiSelect();
                    }
                  : null,
              icon: const Icon(Symbols.download),
            ),
            AddBookmarksButton(
              posts: selectedPosts,
              onPressed: controller.disableMultiSelect,
            ),
            if (extraActions != null) ...extraActions!,
          ],
        );
      },
    );
  }
}
