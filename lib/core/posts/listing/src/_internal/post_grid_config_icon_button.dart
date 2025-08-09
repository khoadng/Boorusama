// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

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
    super.key,
    this.showBlacklist = true,
  });

  final PostGridController<Post> postController;
  final bool showBlacklist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionModeController = SelectionMode.of(context);

    return ListenableBuilder(
      listenable: selectionModeController,
      builder: (context, _) {
        return !selectionModeController.isActive
            ? _buildMenuButton(context, ref)
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildMenuButton(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (_, ref, _) {
        final config = ref.watchConfigFilter;

        final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);
        final postStatsPageBuilder = ref
            .watch(booruBuilderProvider(config.auth))
            ?.postStatisticsPageBuilder;

        final blacklistEntries = ref
            .watch(blacklistTagEntriesProvider(config))
            .valueOrNull;
        final selectionModeController = SelectionMode.of(context);

        return ValueListenableBuilder(
          valueListenable: postController.itemsNotifier,
          builder: (_, posts, _) {
            return posts.isNotEmpty
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          context.extendedColorScheme.surfaceContainerOverlay,
                    ),
                    child: BooruPopupMenuButton(
                      offset: const Offset(0, 36),
                      iconColor:
                          context.extendedColorScheme.onSurfaceContainerOverlay,
                      onSelected: (value) {
                        if (value == 'options') {
                          _showViewOptions(context, settingsNotifier);
                        } else if (value == 'select') {
                          selectionModeController.enable();
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
                          final isGlobal =
                              blacklistEntries?.every(
                                (element) =>
                                    element.source == BlacklistSource.global,
                              ) ??
                              false;

                          if (isGlobal) {
                            goToGlobalBlacklistedTagsPage(ref);
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
                          title: Text(context.t.generic.action.select),
                          icon: const Icon(
                            Symbols.select_all,
                            size: 18,
                          ),
                        ),
                        if (postStatsPageBuilder != null)
                          'stats': const PostGridConfigOptionTile(
                            title: Text('Stats'),
                            icon: Icon(
                              Symbols.bar_chart,
                              size: 18,
                            ),
                          ),
                        if (showBlacklist &&
                            blacklistEntries != null &&
                            blacklistEntries.isNotEmpty)
                          'edit_blacklist': const PostGridConfigOptionTile(
                            title: Text('Edit Blacklist'),
                            icon: Icon(
                              Symbols.block,
                              size: 18,
                            ),
                          ),
                        'options': const PostGridConfigOptionTile(
                          title: Text('View Options'),
                          icon: Icon(
                            Symbols.settings,
                            size: 18,
                          ),
                        ),
                      },
                    ),
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

    return ref
        .watch(blacklistTagEntriesProvider(config))
        .when(
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
                              goToGlobalBlacklistedTagsPage(ref);
                            } else if (e == BlacklistSource.config) {
                              goToUpdateBooruConfigPage(
                                ref,
                                config: ref.readConfig,
                                initialTab: 'search',
                              );
                            } else {
                              //FIXME: if more booru specific blacklist pages are added, we should move this to the builder
                              if (config.auth.booruType == BooruType.danbooru) {
                                goToBlacklistedTagPage(ref);
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          title: switch (e) {
                            BlacklistSource.global => Text(
                              context.t.blacklisted_tags.edit_global_blacklist,
                            ),
                            BlacklistSource.booruSpecific => Text(
                              context
                                  .t
                                  .blacklisted_tags
                                  .edit_booru_specific_blacklist,
                            ),
                            BlacklistSource.config => Text(
                              context.t.blacklisted_tags.edit_profile_blacklist,
                            ),
                          },
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      context.t.blacklist.manage.empty_blacklist,
                    ),
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
    final gridSize = ref.watch(
      imageListingSettingsProvider.select((value) => value.gridSize),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final pageMode = ref.watch(
      imageListingSettingsProvider.select((value) => value.pageMode),
    );
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
                    title: Text(context.t.settings.result_layout.result_layout),
                    selectedOption: pageMode,
                    items: const [...PageMode.values],
                    onChanged: (value) => onModeChanged(value),
                    optionBuilder: (value) => Text(value.localize(context)),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<GridSize>(
                    title: Text(
                      context.t.settings.image_grid.grid_size.grid_size,
                    ),
                    selectedOption: gridSize,
                    items: kSortedGridSizes,
                    onChanged: (value) => onGridChanged(value),
                    optionBuilder: (value) => Text(value.localize(context)),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<ImageListType>(
                    title: Text(context.t.settings.image_list.image_list),
                    selectedOption: imageListType,
                    items: ImageListType.values,
                    onChanged: (value) => onImageListChanged(value),
                    optionBuilder: (value) => Text(value.localize(context)),
                    visualDensity: VisualDensity.compact,
                  ),
                  SettingsTile<ImageQuality>(
                    title: Text(
                      context.t.settings.image_grid.image_quality.image_quality,
                    ),
                    selectedOption: imageQuality,
                    items: [...ImageQuality.values]
                      ..remove(ImageQuality.original),
                    onChanged: (value) => onImageQualityChanged(value),
                    optionBuilder: (value) => Text(value.localize(context)),
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
                openAppearancePage(ref);
              },
              child: Text(context.t.generic.action.more),
            ),
          ),
        ],
      ),
    );
  }
}
