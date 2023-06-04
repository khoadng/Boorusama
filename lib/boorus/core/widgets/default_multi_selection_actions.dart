// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/add_bookmarks_button.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

class DefaultMultiSelectionActions extends StatelessWidget {
  const DefaultMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final List<Post> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
