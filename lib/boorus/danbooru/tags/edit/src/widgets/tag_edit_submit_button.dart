// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/router.dart';
import '../../../_shared/tag_list_notifier.dart';
import '../providers/providers.dart';
import '../providers/tag_edit_notifier.dart';

class TagEditSubmitButton extends ConsumerWidget {
  const TagEditSubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final initialRating = notifier.initialRating;
    final postId = notifier.postId;
    final addedTags =
        ref.watch(tagEditProvider.select((value) => value.toBeAdded));
    final removedTags =
        ref.watch(tagEditProvider.select((value) => value.toBeRemoved));
    final rating = ref.watch(selectedTagEditRatingProvider(initialRating));

    return TextButton(
      onPressed: (addedTags.isNotEmpty ||
              removedTags.isNotEmpty ||
              rating != initialRating)
          ? () {
              ref
                  .read(danbooruTagListProvider(ref.readConfigAuth).notifier)
                  .setTags(
                    postId,
                    addedTags: addedTags.toList(),
                    removedTags: removedTags.toList(),
                    rating: rating != initialRating ? rating : null,
                  );
              context.pop();
            }
          : null,
      child: const Text('Submit'),
    );
  }
}
