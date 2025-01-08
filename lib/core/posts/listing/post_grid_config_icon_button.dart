// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';

class PostGridConfigIconButton<T> extends ConsumerWidget {
  const PostGridConfigIconButton({
    super.key,
    required this.postController,
  });

  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.watch(settingsProvider.notifier);

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => showMaterialModalBottomSheet(
        context: context,
        settings: RouteSettings(name: 'grid_config'),
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
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: const Icon(
          Symbols.settings,
          fill: 1,
        ),
      ),
    );
  }
}

class PostGridActionSheet extends ConsumerWidget {
  const PostGridActionSheet({
    super.key,
    required this.onModeChanged,
    required this.onGridChanged,
    required this.onImageListChanged,
    required this.onImageQualityChanged,
    required this.postController,
  });

  final void Function(PageMode mode) onModeChanged;
  final void Function(GridSize grid) onGridChanged;
  final void Function(ImageListType imageListType) onImageListChanged;
  final void Function(ImageQuality imageQuality) onImageQualityChanged;

  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postStatsPageBuilder =
        ref.watchBooruBuilder(ref.watchConfig)?.postStatisticsPageBuilder;

    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final pageMode = ref
        .watch(imageListingSettingsProvider.select((value) => value.pageMode));
    final imageQuality = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageQuality));

    return Material(
      color: context.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
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
                data: Theme.of(context).copyWith(
                  listTileTheme: ListTileTheme.of(context).copyWith(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    visualDensity: VisualDensity.comfortable,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsTile<PageMode>(
                      title: const Text('settings.result_layout.result_layout')
                          .tr(),
                      selectedOption: pageMode,
                      items: const [...PageMode.values],
                      onChanged: (value) => onModeChanged(value),
                      optionBuilder: (value) => Text(value.localize()).tr(),
                    ),
                    SettingsTile<GridSize>(
                      title:
                          const Text('settings.image_grid.grid_size.grid_size')
                              .tr(),
                      selectedOption: gridSize,
                      items: GridSize.values,
                      onChanged: (value) => onGridChanged(value),
                      optionBuilder: (value) => Text(value.localize().tr()),
                    ),
                    SettingsTile<ImageListType>(
                      title: const Text('settings.image_list.image_list').tr(),
                      selectedOption: imageListType,
                      items: ImageListType.values,
                      onChanged: (value) => onImageListChanged(value),
                      optionBuilder: (value) => Text(value.localize()).tr(),
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
                                  context.navigator.pop();
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    settings:
                                        RouteSettings(name: 'post_statistics'),
                                    duration: AppDurations.bottomSheet,
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
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: () {
                context.navigator.pop();
                openAppearancePage(context);
              },
              child: const Text('More'),
            ),
            SizedBox(
              height: MediaQuery.viewPaddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}
