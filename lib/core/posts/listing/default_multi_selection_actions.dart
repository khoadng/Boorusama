// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/widgets/add_bookmarks_button.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../post.dart';

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
