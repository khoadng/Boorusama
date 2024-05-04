// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/pages/bookmarks/add_bookmarks_button.dart';

class DanbooruMultiSelectionActions extends ConsumerWidget {
  const DanbooruMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final List<DanbooruPost> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ButtonBar(
      alignment: MainAxisAlignment.center,
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
        if (config.hasLoginDetails())
          IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () async {
                    final shouldEnd = await goToAddToFavoriteGroupSelectionPage(
                      context,
                      selectedPosts,
                    );
                    if (shouldEnd != null && shouldEnd) {
                      endMultiSelect();
                    }
                  }
                : null,
            icon: const Icon(Symbols.add),
          ),
      ],
    );
  }
}
