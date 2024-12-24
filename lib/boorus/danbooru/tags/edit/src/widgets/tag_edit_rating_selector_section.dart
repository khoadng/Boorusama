// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/rating/rating.dart';
import '../../../../../../core/widgets/widgets.dart';
import 'tag_how_to_rate_button.dart';

class TagEditRatingSelectorSection extends ConsumerWidget {
  const TagEditRatingSelectorSection({
    required this.rating,
    required this.onChanged,
    super.key,
  });

  final Rating? rating;
  final void Function(Rating rating) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return LayoutBuilder(
      builder: (context, constraints) => Column(
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
                if (!config.hasStrictSFW) const TagHowToRateButton(),
              ],
            ),
          ),
          Center(
            child: BooruSegmentedButton(
              segments: {
                for (final rating
                    in Rating.values.where((e) => e != Rating.unknown))
                  rating: constraints.maxWidth > 360
                      ? rating.name.sentenceCase
                      : rating.name.sentenceCase
                          .getFirstCharacter()
                          .toUpperCase(),
              },
              initialValue: rating,
              onChanged: onChanged,
              fixedWidth: constraints.maxWidth < 360 ? 36 : null,
            ),
          ),
        ],
      ),
    );
  }
}
