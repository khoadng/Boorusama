// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../../../router.dart';

class CurrentBooruTile extends ConsumerWidget {
  const CurrentBooruTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment: constraints.maxWidth <= kMinSideBarWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const _Logo(),
          if (constraints.maxWidth > kMinSideBarWidth)
            const Expanded(
              child: _Tile(),
            ),
          if (constraints.maxWidth > 200) const _EditConfigButton(),
        ],
      ),
    );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: BooruLogo.fromConfig(config),
    );
  }
}

class _Tile extends ConsumerWidget {
  const _Tile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PostSource.from(config.url).whenWeb(
            (source) => source.uri.host,
            () => config.url,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        if (config.hasLoginDetails())
          Text(
            config.login ?? 'Unknown',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

class _EditConfigButton extends ConsumerWidget {
  const _EditConfigButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final configs = ref.watch(booruConfigProvider);

    final hasConfigs = configs.isNotEmpty;

    if (!hasConfigs) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => goToUpdateBooruConfigPage(
          context,
          config: config,
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          child: const Icon(
            Symbols.more_vert,
            fill: 1,
          ),
        ),
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
    final enableDynamicColoring = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

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
