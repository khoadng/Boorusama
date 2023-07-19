// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/booru_logo.dart';
import 'package:boorusama/widgets/square_chip.dart';

class CurrentBooruTile extends ConsumerWidget {
  const CurrentBooruTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final booru = ref.watch(currentBooruProvider);

    final logo = switch (PostSource.from(booruConfig.url)) {
      WebSource s => BooruLogo(source: s),
      _ => const SizedBox.shrink(),
    };

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth > 62
          ? ListTile(
              horizontalTitleGap: 0,
              minLeadingWidth: 36,
              contentPadding: const EdgeInsets.only(left: 8),
              leading: logo,
              title: Wrap(
                children: [
                  Text(
                    booruConfig.isUnverified(booru)
                        ? Uri.parse(booruConfig.url).host
                        : booru.booruType.stringify(),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (booruConfig.ratingFilter !=
                      BooruConfigRatingFilter.none) ...[
                    const SizedBox(width: 4),
                    SquareChip(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      label: Text(
                        booruConfig.ratingFilter.getRatingTerm().toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      color: booruConfig.ratingFilter ==
                              BooruConfigRatingFilter.hideNSFW
                          ? Colors.green
                          : const Color.fromARGB(255, 154, 138, 0),
                    ),
                  ],
                ],
              ),
              subtitle: booruConfig.hasLoginDetails()
                  ? Text(
                      booruConfig.login ?? 'Unknown',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
            )
          : logo,
    );
  }
}
