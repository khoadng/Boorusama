// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/ui/bookmarks/add_bookmarks_button.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';

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
