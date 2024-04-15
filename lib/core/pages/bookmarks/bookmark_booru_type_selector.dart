// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';
import 'providers.dart';

class BookmarkBooruSourceUrlSelector extends ConsumerWidget {
  const BookmarkBooruSourceUrlSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceOptionSelectorList(
      options: ref.watch(availableBooruUrlsProvider),
      sheetTitle: 'Source',
      onSelected: (value) {
        ref.read(selectedBooruUrlProvider.notifier).state = value;
      },
      selectedOption: ref.watch(selectedBooruUrlProvider),
    );
  }
}
