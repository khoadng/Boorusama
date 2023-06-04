// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/add_bookmarks_button.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

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
    final authenticationState = ref.watch(authenticationProvider);

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        DownloadProviderWidget(
          builder: (context, download) => IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () {
                    // ignore: prefer_foreach
                    for (final p in selectedPosts) {
                      download(p);
                    }

                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.download),
          ),
        ),
        AddBookmarksButton(
          posts: selectedPosts,
          onPressed: endMultiSelect,
        ),
        if (authenticationState is Authenticated)
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
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }
}
