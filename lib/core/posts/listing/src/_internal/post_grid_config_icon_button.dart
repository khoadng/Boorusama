// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/routes.dart';
import '../../../../settings/settings.dart';
import '../../../../settings/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../widgets/post_grid_controller.dart';

class PostGridConfigIconButton<T> extends ConsumerWidget {
  const PostGridConfigIconButton({
    required this.postController,
    required this.multiSelectController,
    super.key,
  });

  final PostGridController<Post> postController;
  final MultiSelectController<Post> multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);

    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (context, multiSelect, child) {
        return !multiSelect
            ? Container(
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.extendedColorScheme.surfaceContainerOverlay,
                ),
                child: BooruPopupMenuButton(
                  offset: const Offset(0, 48),
                  iconColor:
                      context.extendedColorScheme.onSurfaceContainerOverlay,
                  onSelected: (value) {
                    if (value == 'options') {
                      _showViewOptions(context, settingsNotifier);
                    } else if (value == 'select') {
                      multiSelectController.enableMultiSelect();
                    }
                  },
                  itemBuilder: {
                    'select': const Text('Select').tr(),
                    'options': const Text('View Options').tr(),
                  },
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Future<void> _showViewOptions(
    BuildContext context,
    SettingsNotifier settingsNotifier,
  ) {
    return showBooruModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: 'grid_config'),
      builder: (_) => PostGridActionSheet(
        postController: postController,
        onModeChanged: (mode) => settingsNotifier.updateWith(
          (s) => s.copyWith(
            listing: s.listing.copyWith(pageMode: mode),
          ),
        ),
        onGridChanged: (grid) => settingsNotifier.updateWith(
          (s) => s.copyWith(
            listing: s.listing.copyWith(gridSize: grid),
          ),
        ),
        onImageListChanged: (imageListType) => settingsNotifier.updateWith(
          (s) => s.copyWith(
            listing: s.listing.copyWith(imageListType: imageListType),
          ),
        ),
        onImageQualityChanged: (imageQuality) => settingsNotifier.updateWith(
          (s) => s.copyWith(
            listing: s.listing.copyWith(imageQuality: imageQuality),
          ),
        ),
      ),
    );
  }
}

class PostGridActionSheet extends ConsumerWidget {
  const PostGridActionSheet({
    required this.onModeChanged,
    required this.onGridChanged,
    required this.onImageListChanged,
    required this.onImageQualityChanged,
    required this.postController,
    super.key,
  });

  final void Function(PageMode mode) onModeChanged;
  final void Function(GridSize grid) onGridChanged;
  final void Function(ImageListType imageListType) onImageListChanged;
  final void Function(ImageQuality imageQuality) onImageQualityChanged;

  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postStatsPageBuilder =
        ref.watch(currentBooruBuilderProvider)?.postStatisticsPageBuilder;

    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final pageMode = ref
        .watch(imageListingSettingsProvider.select((value) => value.pageMode));
    final imageQuality = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageQuality),
    );

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListingSettingsInteractionBlocker(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            child: Theme(
              data: theme.copyWith(
                listTileTheme: ListTileTheme.of(context).copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  visualDensity: VisualDensity.comfortable,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsTile<PageMode>(
                    title:
                        const Text('settings.result_layout.result_layout').tr(),
                    selectedOption: pageMode,
                    items: const [...PageMode.values],
                    onChanged: (value) => onModeChanged(value),
                    optionBuilder: (value) => Text(value.localize()).tr(),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<GridSize>(
                    title: const Text('settings.image_grid.grid_size.grid_size')
                        .tr(),
                    selectedOption: gridSize,
                    items: GridSize.values,
                    onChanged: (value) => onGridChanged(value),
                    optionBuilder: (value) => Text(value.localize().tr()),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<ImageListType>(
                    title: const Text('settings.image_list.image_list').tr(),
                    selectedOption: imageListType,
                    items: ImageListType.values,
                    onChanged: (value) => onImageListChanged(value),
                    optionBuilder: (value) => Text(value.localize()).tr(),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<ImageQuality>(
                    title: const Text(
                      'settings.image_grid.image_quality.image_quality',
                    ).tr(),
                    selectedOption: imageQuality,
                    items: [...ImageQuality.values]
                      ..remove(ImageQuality.original),
                    onChanged: (value) => onImageQualityChanged(value),
                    optionBuilder: (value) => Text(value.localize()).tr(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          if (postStatsPageBuilder != null) ...[
            const Divider(),
            ValueListenableBuilder(
              valueListenable: postController.refreshingNotifier,
              builder: (_, refreshing, __) => ValueListenableBuilder(
                valueListenable: postController.itemsNotifier,
                builder: (_, items, __) => !refreshing && items.isEmpty
                    ? const SizedBox.shrink()
                    : ListTile(
                        title: Row(
                          children: [
                            const Text('Stats for nerds'),
                            if (refreshing)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 12,
                                height: 12,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                        onTap: !refreshing
                            ? () {
                                Navigator.of(context).pop();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  routeSettings: const RouteSettings(
                                    name: 'post_statistics',
                                  ),
                                  builder: (_) => postStatsPageBuilder(
                                    context,
                                    postController.items,
                                  ),
                                );
                              }
                            : null,
                      ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppearancePage(context);
            },
            child: const Text('More'),
          ),
        ],
      ),
    );
  }
}
