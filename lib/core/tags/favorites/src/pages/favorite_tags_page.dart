// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../../routers/utils.dart';
import '../../../../search/search/routes.dart';
import '../../../../search/search/widgets.dart';
import '../../../../search/selected_tags/types.dart';
import '../providers/favorite_tags_notifier.dart';
import '../providers/local_providers.dart';
import '../types/favorite_tag.dart';
import '../types/favorite_tag_filter_type.dart';
import '../types/favorite_tag_group_type.dart';
import '../types/favorite_tags_sort_type.dart';
import '../widgets/favorite_tag_label_chip.dart';
import '../widgets/favorite_tags_filter_scope.dart';
import 'edit_favorite_tag_sheet.dart';
import 'favorite_tag_labels_page.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

class FavoriteTagsPage extends ConsumerWidget {
  const FavoriteTagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(favoriteTagsProvider.notifier);
    final allTags = ref.watch(favoriteTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.favorite_tags.title),
        actions: [
          IconButton(
            tooltip: context.t.favorite_tags.manage_labels,
            onPressed: () => _goToLabelsPage(context),
            icon: const Icon(Symbols.label, fill: 1, size: 20),
          ),
          KurumiPopupMenuButton(
            items: [
              KurumiPopupMenuItem(
                title: Text(context.t.settings.backup_and_restore.import),
                icon: const Icon(Symbols.upload),
                onTap: () => goToFavoriteTagImportPage(context),
              ),
              if (allTags.isNotEmpty)
                KurumiPopupMenuItem(
                  title: Text(context.t.settings.backup_and_restore.export),
                  icon: const Icon(Symbols.download),
                  onTap: () => favoritesNotifier.export(
                    onDone: (value) => AppClipboard.copyAndToast(
                      context,
                      value,
                      message: context.t.favorite_tags.export_notification,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        tooltip: context.t.favorite_tags.add_favorite,
        child: const Icon(Symbols.add),
      ),
      body: FavoriteTagsFilterScope(
        initialValue: ref.watch(selectedFavoriteTagLabelProvider),
        sortType: ref.watch(selectedFavoriteTagsSortTypeProvider),
        filterQuery: ref.watch(selectedFavoriteTagQueryProvider),
        filterType: ref.watch(selectedFavoriteTagFilterTypeProvider),
        builder: (context, tags, labels, selectedLabel) => SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchAndFilterControls(
                    labels: labels,
                    selectedLabel: selectedLabel,
                    selectedType: ref.watch(
                      selectedFavoriteTagFilterTypeProvider,
                    ),
                    groupType: ref.watch(
                      selectedFavoriteTagGroupTypeProvider,
                    ),
                    sortType: ref.watch(selectedFavoriteTagsSortTypeProvider),
                    onQueryChanged: (value) =>
                        ref
                                .read(
                                  selectedFavoriteTagQueryProvider.notifier,
                                )
                                .state =
                            value,
                    onLabelSelected: (value) => ref
                        .read(selectedFavoriteTagLabelProvider.notifier)
                        .select(value),
                    onTypeSelected: (value) =>
                        ref
                                .read(
                                  selectedFavoriteTagFilterTypeProvider
                                      .notifier,
                                )
                                .state =
                            value,
                    onGroupSelected: (value) =>
                        ref
                                .read(
                                  selectedFavoriteTagGroupTypeProvider.notifier,
                                )
                                .state =
                            value,
                    onSortSelected: (value) =>
                        ref
                                .read(
                                  selectedFavoriteTagsSortTypeProvider.notifier,
                                )
                                .state =
                            value,
                  ),
                  Expanded(
                    child: tags.isEmpty
                        ? _EmptyFavoriteTagsView(
                            hasFavorites: allTags.isNotEmpty,
                          )
                        : _FavoriteTagsList(
                            tags: tags,
                            groupType: ref.watch(
                              selectedFavoriteTagGroupTypeProvider,
                            ),
                            selectedLabel: selectedLabel,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToLabelsPage(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        settings: const RouteSettings(name: 'favorite_tag_labels'),
        builder: (context) => const FavoriteTagLabelsPage(),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final duplicateError = context.t.favorite_tags.duplicate_error;
    Kurumi.showAppModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: 'add_favorite_tag'),
      resizeToAvoidBottomInset: true,
      showDragHandle: false,
      builder: (context) => EditFavoriteTagSheet(
        initialValue: FavoriteTag.empty(),
        availableLabels: ref.read(favoriteTagLabelsProvider),
        onSubmit: (tag) async {
          final added = await ref
              .read(favoriteTagsProvider.notifier)
              .add(
                tag.name,
                labels: tag.labels,
                isRaw: tag.queryType == QueryType.simple,
              );
          return added ? null : duplicateError;
        },
      ),
    );
  }
}

class _SearchAndFilterControls extends StatelessWidget {
  const _SearchAndFilterControls({
    required this.labels,
    required this.selectedLabel,
    required this.selectedType,
    required this.groupType,
    required this.sortType,
    required this.onQueryChanged,
    required this.onLabelSelected,
    required this.onTypeSelected,
    required this.onGroupSelected,
    required this.onSortSelected,
  });

  final List<String> labels;
  final String selectedLabel;
  final FavoriteTagFilterType selectedType;
  final FavoriteTagGroupType groupType;
  final FavoriteTagsSortType sortType;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onLabelSelected;
  final ValueChanged<FavoriteTagFilterType> onTypeSelected;
  final ValueChanged<FavoriteTagGroupType> onGroupSelected;
  final ValueChanged<FavoriteTagsSortType> onSortSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final filterButtonBorder = BorderSide(
      color: colorScheme.outlineVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BooruSearchBar(
            hintText: context.t.favorite_tags.search_hint,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Symbols.search),
            ),
            onChanged: onQueryChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                KurumiOptionDropDownButton<FavoriteTagFilterType>(
                  value: selectedType,
                  backgroundColor: Colors.transparent,
                  borderSide: filterButtonBorder,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  arrowSize: 18,
                  arrowSpacing: 6,
                  selectedItemFlexible: false,
                  showSelectedCheckmark: true,
                  selectedItemBuilder: (type) => Text(
                    _typeLabel(type, context),
                    maxLines: 1,
                    style: Kurumi.themeOf(context).textTheme.bodyMedium,
                  ),
                  onChanged: (value) {
                    if (value != null) onTypeSelected(value);
                  },
                  items: [
                    for (final type in FavoriteTagFilterType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(type, context)),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                KurumiOptionDropDownButton<String>(
                  value: selectedLabel,
                  backgroundColor: Colors.transparent,
                  borderSide: filterButtonBorder,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  arrowSize: 18,
                  arrowSpacing: 6,
                  selectedItemFlexible: false,
                  selectedItemBuilder: (label) => ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.widthOf(context) * 0.6,
                    ),
                    child: Text(
                      label.isEmpty
                          ? context.t.favorite_tags.filter.any_label
                          : label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Kurumi.themeOf(context).textTheme.bodyMedium,
                    ),
                  ),
                  onPressed: () => _showLabelPicker(context),
                  onChanged: (_) {},
                  items: [
                    DropdownMenuItem(
                      value: selectedLabel,
                      child: Text(
                        selectedLabel.isEmpty
                            ? context.t.favorite_tags.filter.any_label
                            : selectedLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                KurumiOptionDropDownButton<FavoriteTagGroupType>(
                  value: groupType,
                  backgroundColor: Colors.transparent,
                  borderSide: filterButtonBorder,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  arrowSize: 18,
                  arrowSpacing: 6,
                  selectedItemFlexible: false,
                  showSelectedCheckmark: true,
                  selectedItemBuilder: (type) => Text(
                    _groupLabel(type, context),
                    maxLines: 1,
                    style: Kurumi.themeOf(context).textTheme.bodyMedium,
                  ),
                  onChanged: (value) {
                    if (value != null) onGroupSelected(value);
                  },
                  items: [
                    for (final type in FavoriteTagGroupType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(_groupLabel(type, context)),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                KurumiOptionDropDownButton<FavoriteTagsSortType>(
                  value: sortType,
                  backgroundColor: Colors.transparent,
                  borderSide: filterButtonBorder,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  arrowSize: 18,
                  arrowSpacing: 6,
                  selectedItemFlexible: false,
                  showSelectedCheckmark: true,
                  selectedItemBuilder: (type) => Text(
                    _sortLabel(type, context),
                    maxLines: 1,
                    style: Kurumi.themeOf(context).textTheme.bodyMedium,
                  ),
                  onChanged: (value) {
                    if (value != null) onSortSelected(value);
                  },
                  items: [
                    for (final type in FavoriteTagsSortType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(_sortLabel(type, context)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _sortLabel(FavoriteTagsSortType type, BuildContext context) =>
      switch (type) {
        FavoriteTagsSortType.recentlyAdded => context.t.sort.recently_added,
        FavoriteTagsSortType.recentlyUpdated => context.t.sort.recently_updated,
        FavoriteTagsSortType.nameAZ => context.t.sort.name_asc,
        FavoriteTagsSortType.nameZA => context.t.sort.name_desc,
      };

  String _typeLabel(FavoriteTagFilterType type, BuildContext context) =>
      switch (type) {
        FavoriteTagFilterType.all => context.t.favorite_tags.filter.all_types,
        FavoriteTagFilterType.tags => context.t.tags.title,
        FavoriteTagFilterType.rawQueries => context.t.favorite_tags.filter.raw,
      };

  String _groupLabel(FavoriteTagGroupType type, BuildContext context) =>
      switch (type) {
        FavoriteTagGroupType.none => context.t.favorite_tags.filter.no_group,
        FavoriteTagGroupType.label => context.t.favorite_tags.filter.by_label,
      };

  Future<void> _showLabelPicker(BuildContext context) async {
    final label = await showOptionSearchableSheet<String>(
      context,
      title: context.t.favorite_tags.filter.label_picker_title,
      items: ['', ...labels],
      optionValueBuilder: (label) =>
          label.isEmpty ? context.t.favorite_tags.filter.any_label : label,
    );
    if (label != null) onLabelSelected(label);
  }
}

class _FavoriteTagsList extends ConsumerWidget {
  const _FavoriteTagsList({
    required this.tags,
    required this.groupType,
    required this.selectedLabel,
  });

  final List<FavoriteTag> tags;
  final FavoriteTagGroupType groupType;
  final String selectedLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerColor = Kurumi.themeOf(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.4);

    if (groupType == FavoriteTagGroupType.none) {
      return ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: tags.length,
        itemBuilder: (context, index) => _FavoriteTagTile(tag: tags[index]),
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
        ),
      );
    }

    final groups = _groupByLabel(tags, selectedLabel: selectedLabel);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      children: [
        for (final entry in groups.entries)
          _FavoriteTagGroup(
            label: entry.key,
            tags: entry.value,
            dividerColor: dividerColor,
          ),
      ],
    );
  }

  Map<String, List<FavoriteTag>> _groupByLabel(
    List<FavoriteTag> tags, {
    required String selectedLabel,
  }) {
    if (selectedLabel.isNotEmpty) {
      return {selectedLabel: tags};
    }

    final groups = <String, List<FavoriteTag>>{};
    for (final tag in tags) {
      final labels = tag.labels?.toSet() ?? const <String>{};
      if (labels.isEmpty) {
        groups.putIfAbsent('', () => []).add(tag);
        continue;
      }

      for (final label in labels) {
        groups.putIfAbsent(label, () => []).add(tag);
      }
    }

    final sortedLabels = groups.keys.where((label) => label.isNotEmpty).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return {
      for (final label in sortedLabels) label: groups[label]!,
      if (groups.containsKey('')) '': groups['']!,
    };
  }
}

class _FavoriteTagGroup extends StatelessWidget {
  const _FavoriteTagGroup({
    required this.label,
    required this.tags,
    required this.dividerColor,
  });

  final String label;
  final List<FavoriteTag> tags;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final displayLabel = label.isEmpty
        ? context.t.favorite_tags.unlabelled
        : label;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel.toUpperCase(),
                    style: Kurumi.themeOf(context).textTheme.labelMedium
                        ?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
                Text(
                  '${tags.length}',
                  style: Kurumi.themeOf(context).textTheme.labelMedium
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Material(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < tags.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                  _FavoriteTagTile(
                    tag: tags[index],
                    showLabels: false,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FavoriteTagTile extends ConsumerWidget {
  const _FavoriteTagTile({required this.tag, this.showLabels = true});

  final FavoriteTag tag;
  final bool showLabels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = tag.labels ?? const <String>[];
    final isRaw = tag.queryType == QueryType.simple;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        minVerticalPadding: 10,
        title: Row(
          children: [
            Flexible(
              child: Text(
                tag.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRaw) ...[
              const SizedBox(width: 8),
              const _RawQueryChip(),
            ],
          ],
        ),
        onTap: () => goToSearchPage(
          ref,
          tag: tag.name,
          queryType: tag.queryType,
        ),
        subtitle: showLabels && labels.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in labels)
                      FavoriteTagLabelChip(label: label),
                  ],
                ),
              )
            : null,
        trailing: KurumiPopupMenuButton(
          items: [
            KurumiPopupMenuItem(
              title: Text(context.t.generic.action.edit),
              icon: const Icon(Symbols.edit),
              onTap: () => _edit(context, ref),
            ),
            KurumiPopupMenuItem(
              title: Text(context.t.favorite_tags.copy_exact_value),
              icon: const Icon(Symbols.content_copy),
              onTap: () => AppClipboard.copyWithDefaultToast(context, tag.name),
            ),
            KurumiPopupMenuItem(
              title: Text(context.t.generic.action.delete),
              icon: const Icon(Symbols.delete),
              onTap: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _edit(BuildContext context, WidgetRef ref) {
    final duplicateError = context.t.favorite_tags.duplicate_error;
    Kurumi.showAppModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: 'edit_favorite_tag'),
      resizeToAvoidBottomInset: true,
      showDragHandle: false,
      builder: (context) => EditFavoriteTagSheet(
        initialValue: tag,
        availableLabels: ref.read(favoriteTagLabelsProvider),
        onSubmit: (updated) async {
          final success = await ref
              .read(favoriteTagsProvider.notifier)
              .update(tag.name, updated);
          return success ? null : duplicateError;
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final deleted = await ref
        .read(favoriteTagsProvider.notifier)
        .remove(tag.name);
    if (!context.mounted || deleted == null) return;

    Kurumi.showSimpleSnackBar(
      context: context,
      content: Text(context.t.favorite_tags.deleted),
      action: SnackBarAction(
        label: context.t.favorite_tags.undo,
        onPressed: () =>
            ref.read(favoriteTagsProvider.notifier).restore(deleted),
      ),
    );
  }
}

class _RawQueryChip extends StatelessWidget {
  const _RawQueryChip();

  @override
  Widget build(BuildContext context) {
    final theme = Kurumi.themeOf(context);

    return Semantics(
      label: context.t.search.raw_query,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: StadiumBorder(
              side: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(
              context.t.favorite_tags.raw_badge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavoriteTagsView extends StatelessWidget {
  const _EmptyFavoriteTagsView({required this.hasFavorites});

  final bool hasFavorites;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          hasFavorites
              ? context.t.favorite_tags.filtered_empty
              : context.t.favorite_tags.empty,
          textAlign: TextAlign.center,
          style: Kurumi.themeOf(context).textTheme.bodyLarge?.copyWith(
            color: Kurumi.themeOf(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
