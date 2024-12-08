// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_how_to_rate_button.dart';

class TagEditRatingSelectorSection extends ConsumerWidget {
  const TagEditRatingSelectorSection({
    super.key,
    required this.rating,
    required this.onChanged,
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
