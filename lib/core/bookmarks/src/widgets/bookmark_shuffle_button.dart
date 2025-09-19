// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../providers/bookmark_shuffle_provider.dart';
import '../providers/local_providers.dart';

class BookmarkShuffleButton extends ConsumerWidget {
  const BookmarkShuffleButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortType = ref.watch(selectedBookmarkSortTypeProvider);
    final shuffleNotifier = ref.watch(bookmarkShuffleProvider.notifier);

    if (sortType != BookmarkSortType.random) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        shuffleNotifier.shuffle();
      },
      icon: const Icon(Icons.shuffle),
      tooltip: context.t.bookmark.shuffle_tooltip,
    );
  }
}
