// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_edit_tag_tile.dart';

final tagEditTagFilterModeProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final tagEditCurrentFilterProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final tagEditFilteredListProvider =
    Provider.autoDispose.family<List<String>, Set<String>>((ref, tags) {
  final filter = ref.watch(tagEditCurrentFilterProvider);

  if (filter.isEmpty) return tags.toList();

  return tags.where((tag) => tag.contains(filter)).toList();
});

final danbooruTagEditColorProvider =
    FutureProvider.autoDispose<Map<String, ChipColors?>>(
  (ref) async {
    final tags = ref.watch(_tagsProvider);
    final filters = ref.watch(tagEditFilteredListProvider(tags));

    final colors = <String, ChipColors?>{};
    final config = ref.watchConfig;
    final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    final enableDynamicColoring = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    for (final tag in filters) {
      final tagType = await tagTypeStore.get(config.booruType, tag);

      if (tagType == null) {
        colors[tag] = null;
      } else {
        final color = ref.watch(tagColorProvider(tagType));

        final chipColors = color != null && color != Colors.white
            ? generateChipColorsFromColorScheme(
                color,
                colorScheme,
                enableDynamicColoring,
              )
            : null;

        colors[tag] = chipColors;
      }
    }

    return colors;
  },
  dependencies: [
    _tagsProvider,
    colorSchemeProvider,
    settingsProvider,
    tagColorProvider,
    tagEditFilteredListProvider,
    currentBooruConfigProvider,
  ],
);

final _initialTagCountProvider = Provider.autoDispose<int>((ref) {
  throw UnimplementedError();
});

final _tagsProvider = Provider.autoDispose<Set<String>>((ref) {
  throw UnimplementedError();
});

class SliverTagEditTagListSection extends ConsumerWidget {
  const SliverTagEditTagListSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagEditProvider.select((value) => value.tags));
    final initialTags = ref.watch(tagEditProvider.notifier).initialTags;

    return ProviderScope(
      overrides: [
        _initialTagCountProvider.overrideWithValue(initialTags.length),
        _tagsProvider.overrideWithValue(tags),
      ],
      child: MultiSliver(
        children: const [
          SliverDivider(
            thickness: 1,
          ),
          SliverToBoxAdapter(
            child: TagEditFilterHeader(),
          ),
          _SliverTagEditListView(),
        ],
      ),
    );
  }
}

class _SliverTagEditListView extends ConsumerWidget {
  const _SliverTagEditListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(_tagsProvider);
    final filtered = ref.watch(tagEditFilteredListProvider(tags));
    final toBeAdded =
        ref.watch(tagEditProvider.select((value) => value.toBeAdded));
    final notifier = ref.watch(tagEditProvider.notifier);
    //FIXME: Need to fix color flashing when adding tag
    final chipColors = ref.watch(danbooruTagEditColorProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

    return SliverList.builder(
      itemCount: filtered.length,
      itemBuilder: (_, index) {
        final tag = filtered[index];
        final colors = chipColors != null
            ? chipColors.containsKey(tag)
                ? chipColors[tag]
                : null
            : null;

        return TagEditTagTile(
          title: Text(
            tag.replaceAll('_', ' '),
            style: TextStyle(
              color: context.isLight
                  ? colors?.backgroundColor
                  : colors?.foregroundColor,
              fontWeight: toBeAdded.contains(tag) ? FontWeight.w900 : null,
            ),
          ),
          onTap: () => notifier.setSelectedTag(tag),
          onDeleted: () => notifier.removeTag(tag),
        );
      },
    );
  }
}

class TagEditFilterHeader extends ConsumerWidget {
  const TagEditFilterHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterOn = ref.watch(tagEditTagFilterModeProvider);
    final tagCount = ref.watch(_initialTagCountProvider);

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 12,
      ),
      child: Row(
        children: [
          Text(
            '$tagCount tag${tagCount > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                ),
          ),
          filterOn
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: BooruSearchBar(
                            autofocus: true,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            hintText: 'Filter...',
                            onChanged: (value) => ref
                                .read(tagEditCurrentFilterProvider.notifier)
                                .state = value,
                          ),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              shape: const CircleBorder(),
                              backgroundColor: context.colorScheme.primary),
                          onPressed: () {
                            ref
                                .read(tagEditTagFilterModeProvider.notifier)
                                .state = false;
                            ref
                                .read(tagEditCurrentFilterProvider.notifier)
                                .state = '';
                          },
                          child: Icon(
                            Symbols.check,
                            size: 16,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : IconButton(
                  splashRadius: 20,
                  onPressed: () => ref
                      .read(tagEditTagFilterModeProvider.notifier)
                      .state = true,
                  icon: const Icon(
                    Symbols.filter_list,
                  ),
                ),
          if (!filterOn) const Spacer(),
          if (!filterOn)
            BooruPopupMenuButton(
              itemBuilder: const {
                'fetch_category': Text('Fetch tag category'),
              },
              onSelected: (value) async {
                switch (value) {
                  case 'fetch_category':
                    await _fetch(ref);
                    break;
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _fetch(WidgetRef ref) async {
    final repo = ref.watch(tagRepoProvider(ref.watchConfig));
    final tags = ref.watch(_tagsProvider);

    final t = await repo.getTagsByName(tags, 1);

    await ref
        .watch(booruTagTypeStoreProvider)
        .saveTagIfNotExist(ref.watchConfig.booruType, t);

    ref.invalidate(danbooruTagEditColorProvider);
  }
}
