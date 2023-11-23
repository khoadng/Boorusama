// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';

class BooruSelector extends ConsumerStatefulWidget {
  const BooruSelector({
    super.key,
  });

  @override
  ConsumerState<BooruSelector> createState() => _BooruSelectorState();
}

class _BooruSelectorState extends ConsumerState<BooruSelector> {
  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(configsProvider);
    final currentConfig = ref.watchConfig;

    void show(BooruConfig config) {
      context.contextMenuOverlay.show(
        GenericContextMenu(
          buttonConfigs: [
            ContextMenuButtonConfig(
              'generic.action.edit'.tr(),
              onPressed: () => context.go('/boorus/${config.id}/update'),
            ),
            if (currentConfig != config)
              ContextMenuButtonConfig('generic.action.delete'.tr(),
                  onPressed: () =>
                      ref.read(booruConfigProvider.notifier).delete(config)),
          ],
        ),
      );
    }

    void hide() => context.contextMenuOverlay.hide();

    return SizedBox(
      width: 68,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            ReorderableSliverList(
                onReorderStarted: (index) => show(configs[index]),
                onHover: (start, current) => hide(),
                delegate: ReorderableSliverChildBuilderDelegate(
                  (context, index) {
                    final config = configs[index];

                    return BooruSelectorItem(
                      config: config,
                      show: () => show(config),
                      onTap: () => ref
                          .read(currentBooruConfigProvider.notifier)
                          .update(config),
                      selected: currentConfig == config,
                    );
                  },
                  childCount: configs.length,
                ),
                onReorder: (oldIndex, newIndex) {
                  final orders = ref.read(configIdOrdersProvider);
                  final newOrders =
                      (orders.isEmpty || orders.length != configs.length
                              ? [for (final config in configs) config.id]
                              : orders)
                          .toList();

                  newOrders.reorder(oldIndex, newIndex);

                  ref.setBooruConfigOrder(newOrders);
                }),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    IconButton(
                      splashRadius: 20,
                      onPressed: () => context.go('/boorus/add'),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BooruSelectorItem extends StatelessWidget {
  const BooruSelectorItem({
    super.key,
    required this.config,
    required this.onTap,
    required this.show,
    required this.selected,
  });

  final BooruConfig config;
  final bool selected;
  final void Function() show;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey(config.id),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        hoverColor: context.theme.hoverColor.withOpacity(0.1),
        onSecondaryTap: () => show(),
        onTap: onTap,
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color:
                    selected ? context.colorScheme.primary : Colors.transparent,
                width: 6,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              switch (PostSource.from(config.url)) {
                WebSource source => FittedBox(
                    child: ExtendedImage.network(
                      source.faviconUrl,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      clearMemoryCacheIfFailed: false,
                      loadStateChanged: (state) =>
                          switch (state.extendedImageLoadState) {
                        LoadState.failed => const Card(
                            child: FaIcon(
                              FontAwesomeIcons.globe,
                              size: 22,
                              color: Colors.blue,
                            ),
                          ),
                        _ => state.completedWidget,
                      },
                    ),
                  ),
                _ => const Card(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                    ),
                  ),
              },
              const SizedBox(height: 4),
              Text(
                config.name,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
