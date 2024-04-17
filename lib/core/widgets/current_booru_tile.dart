// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings_providers.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class CurrentBooruTile extends ConsumerWidget {
  const CurrentBooruTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final source = PostSource.from(booruConfig.url);

    final logo = switch (source) {
      WebSource s => BooruLogo(
          source: s,
        ),
      _ => const SizedBox.shrink(),
    };

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth > kMinSideBarWidth
          ? Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 6,
              ),
              child: Row(
                children: [
                  logo,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.whenWeb(
                            (source) => source.uri.host,
                            () => booruConfig.url,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        booruConfig.hasLoginDetails()
                            ? Text(
                                booruConfig.login ?? 'Unknown',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.colorScheme.outline,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  if (constraints.maxWidth > 100)
                    if (booruConfig.ratingFilter !=
                        BooruConfigRatingFilter.none) ...[
                      const SizedBox(width: 12),
                      CurrentBooruRatingChip(config: booruConfig),
                    ],
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: logo,
            ),
    );
  }
}

class CurrentBooruRatingChip extends ConsumerWidget {
  const CurrentBooruRatingChip({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableDynamicColoring =
        ref.watch(enableDynamicColoringSettingsProvider);

    return SquareChip(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      label: Text(
        config.ratingFilter.getRatingTerm().toUpperCase(),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      color: config.ratingFilter == BooruConfigRatingFilter.hideNSFW
          ? enableDynamicColoring
              ? Colors.green.harmonizeWith(context.colorScheme.primary)
              : Colors.green
          : enableDynamicColoring
              ? const Color.fromARGB(255, 154, 138, 0)
                  .harmonizeWith(context.colorScheme.primary)
              : const Color.fromARGB(255, 154, 138, 0),
    );
  }
}
