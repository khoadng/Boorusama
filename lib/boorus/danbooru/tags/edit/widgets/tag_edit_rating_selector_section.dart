// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../tags.dart';

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
    final config = ref.watchConfig;

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
