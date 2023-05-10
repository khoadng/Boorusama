// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_notifier.dart';
import 'package:boorusama/core/domain/posts.dart';

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
              context.read<BookmarkCubit>().addBookmarksWithToast(
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
