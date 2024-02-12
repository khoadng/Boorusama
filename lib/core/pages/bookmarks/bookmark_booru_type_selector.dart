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
    final options = ref.watch(availableBooruUrlsProvider);

    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedBooruUrlProvider),
      onChanged: (value) =>
          ref.read(selectedBooruUrlProvider.notifier).state = value,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All'),
        ),
        ...options.map(
          (value) => DropdownMenuItem(
            value: value,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
