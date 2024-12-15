// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../providers/local_providers.dart';

class BookmarkBooruSourceUrlSelector extends ConsumerWidget {
  const BookmarkBooruSourceUrlSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 4),
      child: ChoiceOptionSelectorList(
        options: ref.watch(availableBooruUrlsProvider),
        sheetTitle: 'Source',
        onSelected: (value) {
          ref.read(selectedBooruUrlProvider.notifier).state = value;
        },
        selectedOption: ref.watch(selectedBooruUrlProvider),
        optionLabelBuilder: (value) => value ?? 'All',
      ),
    );
  }
}
