// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    FutureProvider.autoDispose.family<Color?, TagEditColorParams>(
  (ref, params) async {
    final tag = params.tag;
    final config = ref.watchConfig;
    final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
    final tagType = await tagTypeStore.get(config.booruType, tag);

    if (tagType == null) return null;

    final color = ref.watch(tagColorProvider(tagType));

    return color;
  },
  dependencies: [
    tagColorProvider,
    currentBooruConfigProvider,
  ],
);

class TagEditTagListSection extends ConsumerWidget {
  const TagEditTagListSection({
    super.key,
    required this.initialTags,
    required this.tags,
    required this.onTagTap,
    required this.onDeleted,
    required this.toBeAdded,
    required this.toBeRemoved,
  });

  final Set<String> initialTags;
  final Set<String> tags;
  final void Function(String tag) onTagTap;
  final void Function(String tag) onDeleted;
  final Set<String> toBeAdded;
  final Set<String> toBeRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(tagEditFilteredListProvider(tags));
    final filterOn = ref.watch(tagEditTagFilterModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 1,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: Row(
            children: [
              Text(
                '${initialTags.length} tag${initialTags.length > 1 ? 's' : ''}',
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
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            itemBuilder: (_, index) {
              final colors = _getColors(filtered[index], context, ref);

              return TagEditTagTile(
                title: Text(
                  filtered[index].replaceAll('_', ' '),
                  style: TextStyle(
                    color: context.isLight
                        ? colors?.backgroundColor
                        : colors?.foregroundColor,
                    fontWeight: toBeAdded.contains(filtered[index])
                        ? FontWeight.w900
                        : null,
                  ),
                ),
                onTap: () => onTagTap(filtered[index]),
                filtered: filtered,
                onDeleted: () => onDeleted(filtered[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _fetch(WidgetRef ref) async {
    final repo = ref.watch(tagRepoProvider(ref.watchConfig));

    final t = await repo.getTagsByName(tags, 1);

    await ref
        .watch(booruTagTypeStoreProvider)
        .saveTagIfNotExist(ref.watchConfig.booruType, t);

    for (final tag in t) {
      final params = (tag: tag.rawName,);
      ref.invalidate(danbooruTagEditColorProvider(params));
    }
  }

  ChipColors? _getColors(String tag, BuildContext context, WidgetRef ref) {
    final params = (tag: tag,);

    final colors = ref.watch(danbooruTagEditColorProvider(params)).maybeWhen(
          data: (color) => color != null && color != Colors.white
              ? generateChipColorsFromColorScheme(
                  color,
                  context.colorScheme,
                  ref.watch(settingsProvider).enableDynamicColoring,
                )
              : null,
          orElse: () => null,
        );

    return colors;
  }
}
