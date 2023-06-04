// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

class AddBookmarksButton extends ConsumerWidget {
  const AddBookmarksButton({
    super.key,
    required this.posts,
    required this.onPressed,
  });

  final List<Post> posts;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return IconButton(
      onPressed: posts.isNotEmpty
          ? () async {
              ref.bookmarks.addBookmarksWithToast(
                booru,
                posts,
              );
              onPressed();
            }
          : null,
      icon: const Icon(Icons.bookmark_add),
    );
  }
}
