// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../bookmarks/widgets.dart';
import '../../../downloads/downloader.dart';
import '../../post/post.dart';

class DefaultMultiSelectionActions<T extends Post> extends ConsumerWidget {
  const DefaultMultiSelectionActions({
    required this.controller,
    super.key,
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
