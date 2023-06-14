// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/booru_logo.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruConfigInfoTile extends StatelessWidget {
  const BooruConfigInfoTile({
    super.key,
    required this.booru,
    required this.config,
    required this.isCurrent,
    this.onTap,
    this.trailing,
    this.selected,
    this.selectedTileColor,
  });

  final Booru booru;
  final BooruConfig config;
  final bool isCurrent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool? selected;
  final Color? selectedTileColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 0,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          switch (PostSource.from(config.url)) {
            WebSource s => BooruLogo(source: s),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
      selected: selected ?? false,
      selectedTileColor: selectedTileColor,
      title: Row(
        children: [
          Text(
            config.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 4),
            SquareChip(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              label: Text(
                'Current'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              color: context.colorScheme.primary,
            ),
          ],
          if (config.ratingFilter == BooruConfigRatingFilter.hideNSFW) ...[
            const SizedBox(width: 4),
            SquareChip(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              label: Text(
                config.ratingFilter.getRatingTerm().toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              color: Colors.green,
            ),
          ],
          if (config.ratingFilter == BooruConfigRatingFilter.hideExplicit) ...[
            const SizedBox(width: 4),
            SquareChip(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              label: Text(
                config.ratingFilter.getRatingTerm().toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              color: const Color.fromARGB(255, 154, 138, 0),
            ),
          ]
        ],
      ),
      subtitle: Text(config.login?.isEmpty ?? true
          ? '<Anonymous>'
          : config.login ?? 'Unknown'),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
