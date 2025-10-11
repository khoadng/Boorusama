// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/rating/rating.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../configs/providers.dart';
import '../../../../tags/edit/widgets.dart';
import '../providers/upload_provider.dart';

class TagEditUploadRatingSelector extends ConsumerWidget {
  const TagEditUploadRatingSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final notifier = ref.watch(danbooruUploadNotifierProvider(config).notifier);
    final rating = ref.watch(
      danbooruUploadNotifierProvider(config).select((state) => state.rating),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(
                'Rating',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!loginDetails.hasStrictSFW) const TagHowToRateButton(),
              const Spacer(),
              OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: rating,
                onChanged: (value) => notifier.updateRating(value),
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
        ),
      ],
    );
  }
}
