// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/uploads/uploads.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_edit_page.dart';

class TagEditUploadPage extends ConsumerWidget {
  const TagEditUploadPage({
    super.key,
    required this.post,
    required this.onSubmitted,
  });

  final DanbooruUploadPost post;
  final void Function() onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final rating = ref.watch(selectedTagEditRatingProvider(null));
    final notifier = ref.watch(danbooruPostCreateProvider(config).notifier);

    ref.listen(
      danbooruPostCreateProvider(config),
      (previous, next) {
        next.when(
          data: (data) {
            if (data != null) {
              onSubmitted();
              context.pop();
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            showErrorToast(
              error.toString(),
              duration: const Duration(seconds: 3),
            );
          },
        );
      },
    );

    return TagEditPageInternal(
      postId: post.id,
      imageUrl: post.url720x720,
      aspectRatio: post.aspectRatio ?? 1,
      tags: const [],
      submitButtonBuilder: (addedTags, removedTags) => TextButton(
        onPressed:
            (addedTags.isNotEmpty && rating != null && post.source.url != null)
                ? ref.watch(danbooruPostCreateProvider(config)).maybeWhen(
                      loading: () => null,
                      orElse: () => () {
                        notifier.create(
                          mediaAssetId: post.mediaAssetId,
                          uploadMediaAssetId: post.uploadMediaAssetId,
                          rating: rating,
                          source: post.source.url!,
                          tags: addedTags,
                        );
                      },
                    )
                : null,
        child: const Text('Submit'),
      ),
      sourceBuilder: () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AutofillGroup(
              child: BooruTextFormField(
                initialValue: post.source.url,
                readOnly: true,
                autocorrect: false,
                keyboardType: TextInputType.url,
                autofillHints: const [
                  AutofillHints.url,
                ],
                validator: (p0) => null,
                decoration: const InputDecoration(
                  labelText: 'Source',
                ),
              ),
            )
          ],
        );
      },
      ratingSelectorBuilder: () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    'Rating',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!config.hasStrictSFW)
                    IconButton(
                      splashRadius: 20,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => launchExternalUrlString(kHowToRateUrl),
                      icon: const Icon(
                        FontAwesomeIcons.circleQuestion,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                OptionDropDownButton(
                  alignment: AlignmentDirectional.centerStart,
                  value: ref.watch(selectedTagEditRatingProvider(null)),
                  onChanged: (value) => ref
                      .read(selectedTagEditRatingProvider(null).notifier)
                      .state = value,
                  items: [...Rating.values.where((e) => e != Rating.unknown)]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name.sentenceCase),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
