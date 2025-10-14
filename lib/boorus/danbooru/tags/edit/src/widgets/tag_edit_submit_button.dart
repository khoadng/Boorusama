// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../_shared/tag_list_notifier.dart';
import '../providers/providers.dart';
import '../providers/tag_edit_notifier.dart';

class TagEditSubmitButton extends ConsumerWidget {
  const TagEditSubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TagEditParamsProvider.of(context);
    final initialRating = params.initialRating;
    final postId = params.postId;
    final addedTags = ref.watch(
      tagEditProvider(params).select((value) => value.toBeAdded),
    );
    final removedTags = ref.watch(
      tagEditProvider(params).select((value) => value.toBeRemoved),
    );
    final rating = ref.watch(selectedTagEditRatingProvider(initialRating));

    return TextButton(
      onPressed:
          (addedTags.isNotEmpty ||
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
              Navigator.of(context).pop();
            }
          : null,
      child: Text('Submit'.hc),
    );
  }
}
