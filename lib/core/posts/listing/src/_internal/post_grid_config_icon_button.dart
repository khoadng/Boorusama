// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../boorus/danbooru/blacklist/routes.dart';
import '../../../../blacklists/providers.dart';
import '../../../../blacklists/routes.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../config_widgets/booru_logo.dart';
import '../../../../configs/create/routes.dart';
import '../../../../configs/ref.dart';
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
    this.showBlacklist = true,
  });

  final PostGridController<Post> postController;
  final MultiSelectController multiSelectController;
  final bool showBlacklist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (context, multiSelect, child) {
        return !multiSelect
            ? Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.extendedColorScheme.surfaceContainerOverlay,
                ),
                child: _buildMenuButton(context, ref),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (_, ref, __) {
        final config = ref.watchConfigFilter;

        final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);
        final postStatsPageBuilder = ref
            .watch(booruBuilderProvider(config.auth))
            ?.postStatisticsPageBuilder;

        final blacklistEntries =
            ref.watch(blacklistTagEntriesProvider(config)).valueOrNull;

        return ValueListenableBuilder(
          valueListenable: postController.itemsNotifier,
          builder: (_, posts, __) {
            return posts.isNotEmpty
                ? BooruPopupMenuButton(
                    offset: const Offset(0, 36),
                    iconColor:
                        context.extendedColorScheme.onSurfaceContainerOverlay,
                    onSelected: (value) {
                      if (value == 'options') {
                        _showViewOptions(context, settingsNotifier);
                      } else if (value == 'select') {
                        multiSelectController.enableMultiSelect();
                      } else if (value == 'stats') {
                        if (postStatsPageBuilder != null) {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              settings: const RouteSettings(
                                name: 'post_statistics',
                              ),
                              builder: (_) => postStatsPageBuilder(
                                context,
                                postController.items,
                              ),
                            ),
                          );
                        }
                      } else if (value == 'edit_blacklist') {
                        // check if all entries are global then just open the global blacklist page
                        final isGlobal = blacklistEntries?.every(
                              (element) =>
                                  element.source == BlacklistSource.global,
                            ) ??
                            false;

                        if (isGlobal) {
                          goToGlobalBlacklistedTagsPage(context);
                        } else {
                          showBooruModalBottomSheet(
                            context: context,
                            routeSettings: const RouteSettings(
                              name: 'edit_blacklist_select',
                            ),
                            builder: (_) => const EditBlacklistActionSheet(),
                          );
                        }
                      }
                    },
                    itemBuilder: {
                      'select': PostGridConfigOptionTile(
                        title: const Text('Select').tr(),
                        icon: const Icon(
                          Symbols.select_all,
                          size: 18,
                        ),
                      ),
                      if (postStatsPageBuilder != null)
                        'stats': PostGridConfigOptionTile(
                          title: const Text('Stats').tr(),
                          icon: const Icon(
                            Symbols.bar_chart,
                            size: 18,
                          ),
                        ),
                      if (showBlacklist &&
                          blacklistEntries != null &&
                          blacklistEntries.isNotEmpty)
                        'edit_blacklist': PostGridConfigOptionTile(
                          title: const Text('Edit Blacklist').tr(),
                          icon: const Icon(
                            Symbols.block,
                            size: 18,
                          ),
                        ),
                      'options': PostGridConfigOptionTile(
                        title: const Text('View Options').tr(),
                        icon: const Icon(
                          Symbols.settings,
                          size: 18,
                        ),
                      ),
                    },
                  )
                : const SizedBox.shrink();
          },
        );
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

class PostGridConfigOptionTile extends StatelessWidget {
  const PostGridConfigOptionTile({
    required this.title,
    required this.icon,
    super.key,
  });

  final Widget title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        title,
      ],
    );
  }
}

class EditBlacklistActionSheet extends ConsumerWidget {
  const EditBlacklistActionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigFilter;
    final colorScheme = Theme.of(context).colorScheme;

    return ref.watch(blacklistTagEntriesProvider(config)).when(
          data: (entries) {
            final sources = entries.map((e) => e.source).toSet();

            return sources.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...sources.map(
                        (e) => ListTile(
                          leading: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: switch (e) {
                              BlacklistSource.global => Image.asset(
                                  'assets/images/logo.png',
                                  width: 24,
                                  height: 24,
                                  isAntiAlias: true,
                                  filterQuality: FilterQuality.none,
                                ),
                              BlacklistSource.booruSpecific => BooruLogo(
                                  source: config.auth.url,
                                  width: 24,
                                  height: 24,
                                ),
                              BlacklistSource.config => Icon(
                                  Icons.settings,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                            },
                          ),
                          onTap: () {
                            if (e == BlacklistSource.global) {
                              goToGlobalBlacklistedTagsPage(context);
                            } else if (e == BlacklistSource.config) {
                              goToUpdateBooruConfigPage(
                                context,
                                config: ref.readConfig,
                                initialTab: 'search',
                              );
                            } else {
                              //FIXME: if more booru specific blacklist pages are added, we should move this to the builder
                              if (config.auth.booruType == BooruType.danbooru) {
                                goToBlacklistedTagPage(context);
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          title: switch (e) {
                            BlacklistSource.global =>
                              const Text('Edit Global Blacklist').tr(),
                            BlacklistSource.booruSpecific =>
                              const Text("Edit Booru's Specific Blacklist")
                                  .tr(),
                            BlacklistSource.config =>
                              const Text('Edit Profile Blacklist').tr(),
                          },
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text('No blacklisted tags'),
                  );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(error.toString()),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppearancePage(context);
              },
              child: const Text('More'),
            ),
          ),
        ],
      ),
    );
  }
}
