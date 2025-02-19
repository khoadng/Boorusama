// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../posts/post/post.dart';
import '../providers/bookmark_provider.dart';

class AddBookmarksButton extends ConsumerWidget {
  const AddBookmarksButton({
    required this.posts,
    required this.onPressed,
    super.key,
  });

  final Iterable<Post> posts;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;

    return IconButton(
      onPressed: posts.isNotEmpty
          ? () async {
              unawaited(
                ref.bookmarks.addBookmarksWithToast(
                  context,
                  booruConfig.booruId,
                  booruConfig.url,
                  posts,
                ),
              );
              onPressed();
            }
          : null,
      icon: const Icon(Symbols.bookmark_add),
    );
  }
}
