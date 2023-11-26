// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/pages/bookmarks/providers.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/widgets.dart';

class BookmarkGridUpdateButtons extends ConsumerWidget {
  const BookmarkGridUpdateButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = Screen.of(context).size;

    return GridSizeAdjustmentButtons(
      minCount: 2,
      maxCount: switch (Screen.of(context).nextBreakpoint()) {
        ScreenSize.small => 2,
        ScreenSize.medium => 4,
        ScreenSize.large => 5,
        ScreenSize.veryLarge => 6,
      },
      count: ref.watch(selectRowCountProvider(size)),
      onAdded: (count) =>
          ref.read(selectRowCountProvider(size).notifier).state = count + 1,
      onDecreased: (count) =>
          ref.read(selectRowCountProvider(size).notifier).state = count - 1,
    );
  }
}
