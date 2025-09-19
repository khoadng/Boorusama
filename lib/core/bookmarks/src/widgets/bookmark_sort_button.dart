// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../providers/bookmark_shuffle_provider.dart';
import '../providers/local_providers.dart';

class BookmarkSortButton extends ConsumerWidget {
  const BookmarkSortButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffleProvider = ref.watch(bookmarkShuffleProvider.notifier);

    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedBookmarkSortTypeProvider),
      onChanged: (value) {
        final newSortType = value ?? BookmarkSortType.newest;
        ref.read(selectedBookmarkSortTypeProvider.notifier).state = newSortType;

        switch (newSortType) {
          case BookmarkSortType.random:
            shuffleProvider.shuffle();
          case _:
            shuffleProvider.reset();
        }
      },
      items: BookmarkSortType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(
                switch (value) {
                  BookmarkSortType.newest => context.t.explore.newest,
                  BookmarkSortType.oldest => context.t.explore.oldest,
                  BookmarkSortType.random => context.t.explore.random,
                },
              ),
            ),
          )
          .toList(),
    );
  }
}
