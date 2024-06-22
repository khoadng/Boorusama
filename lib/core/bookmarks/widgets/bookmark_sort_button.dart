// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/widgets/providers.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class BookmarkSortButton extends ConsumerWidget {
  const BookmarkSortButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedBookmarkSortTypeProvider),
      onChanged: (value) => ref
          .read(selectedBookmarkSortTypeProvider.notifier)
          .state = value ?? BookmarkSortType.newest,
      items: BookmarkSortType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(value.name.sentenceCase),
            ),
          )
          .toList(),
    );
  }
}
