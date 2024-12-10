// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../app.dart';
import '../../../../router.dart';
import '../../../posts/sources/source.dart';
import '../../../widgets/widgets.dart';
import '../booru_config_ref.dart';
import '../providers.dart';

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
    final config = ref.watchConfigAuth;

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
    final config = ref.watchConfigAuth;

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
    final hasConfigs = ref.watch(hasBooruConfigsProvider);

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
