// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/bookmarks/add_bookmarks_button.dart';
import 'package:boorusama/widgets/widgets.dart';

class DefaultMultiSelectionActions extends ConsumerWidget {
  const DefaultMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final Iterable<Post> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiSelectionActionBar(
      children: [
        IconButton(
          onPressed: selectedPosts.isNotEmpty
              ? () {
                  showDownloadStartToast(context);
                  // ignore: prefer_foreach
                  for (final p in selectedPosts) {
                    ref.download(p);
                  }

                  endMultiSelect();
                }
              : null,
          icon: const Icon(Symbols.download),
        ),
        AddBookmarksButton(
          posts: selectedPosts,
          onPressed: endMultiSelect,
        ),
      ],
    );
  }
}
