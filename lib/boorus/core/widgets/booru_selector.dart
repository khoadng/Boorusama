// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';

class BooruSelector extends ConsumerWidget {
  const BooruSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(booruConfigProvider);
    final currentConfig = ref.watch(currentBooruConfigProvider);

    return SizedBox(
      width: 68,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final config in configs)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Material(
                    color: currentConfig == config
                        ? context.colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onSecondaryTap: () => context.contextMenuOverlay.show(
                        GenericContextMenu(
                          buttonConfigs: [
                            ContextMenuButtonConfig(
                              'generic.action.edit'.tr(),
                              onPressed: () =>
                                  context.go('/boorus/${config.id}/update'),
                            ),
                            if (currentConfig != config)
                              ContextMenuButtonConfig(
                                  'generic.action.delete'.tr(),
                                  onPressed: () => ref
                                      .read(booruConfigProvider.notifier)
                                      .delete(config)),
                          ],
                        ),
                      ),
                      onTap: () => ref
                          .read(currentBooruConfigProvider.notifier)
                          .update(config),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            switch (PostSource.from(config.url)) {
                              WebSource source => FittedBox(
                                  child: CachedNetworkImage(
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    fadeInDuration:
                                        const Duration(milliseconds: 100),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 200),
                                    imageUrl: source.faviconUrl,
                                    errorWidget: (context, url, error) =>
                                        const SizedBox.shrink(),
                                    errorListener: (e) {
                                      // Ignore error
                                    },
                                  ),
                                ),
                              _ => const Card(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                            },
                            const SizedBox(height: 4),
                            Text(
                              config.name,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => context.go('/boorus/add'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
