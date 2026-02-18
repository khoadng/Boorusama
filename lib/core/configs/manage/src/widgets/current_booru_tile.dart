// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../config_widgets/website_logo.dart';
import '../../../../posts/sources/types.dart';
import '../../../config/providers.dart';
import '../../../config/types.dart';
import '../../../create/routes.dart';

class CurrentBooruTile extends ConsumerWidget {
  const CurrentBooruTile({
    required this.minWidth,
    super.key,
  });

  final double minWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment: constraints.maxWidth <= minWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const _Logo(),
          if (constraints.maxWidth > minWidth)
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
      child: ConfigAwareWebsiteLogo.fromConfig(
        config.auth,
        customIconUrl: config.profileIcon?.url,
      ),
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
        if (config.login case final login?)
          if (login.isNotEmpty)
            Text(
              login,
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
          ref,
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
