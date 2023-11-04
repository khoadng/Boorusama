// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'providers.dart';

class BookmarkBooruTypeSelector extends ConsumerWidget {
  const BookmarkBooruTypeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(availableBooruOptionsProvider);

    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedBooruProvider),
      onChanged: (value) =>
          ref.read(selectedBooruProvider.notifier).state = value,
      items: options
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(value?.stringify() ?? 'All'),
            ),
          )
          .toList(),
    );
  }
}
