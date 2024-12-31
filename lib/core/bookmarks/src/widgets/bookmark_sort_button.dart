// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../providers/local_providers.dart';

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
