// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/booru_tag_type_store.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_edit_ai_view.dart';
import 'tag_edit_favorite_view.dart';
import 'tag_edit_wiki_view.dart';

enum TagEditExpandMode {
  favorite,
  related,
  aiTag,
}

const _kHowToRateUrl = 'https://danbooru.donmai.us/wiki_pages/howto:rate';

final danbooruTagEditColorProvider =
    FutureProvider.autoDispose.family<Color?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final settings = ref.watch(settingsProvider);
  final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
  final tagType = await tagTypeStore.get(config.booruType, tag);

  final color = ref
      .watch(booruBuilderProvider)
      ?.tagColorBuilder(settings.themeMode, tagType);

  return color;
});

class TagEditPage extends ConsumerStatefulWidget {
  const TagEditPage({
    super.key,
    required this.postId,
    required this.tags,
    required this.rating,
    required this.imageUrl,
    required this.aspectRatio,
  });

  final int postId;
  final String imageUrl;
  final double aspectRatio;
  final List<String> tags;
  final Rating rating;

  @override
  ConsumerState<TagEditPage> createState() => _TagEditViewState();
}

class _TagEditViewState extends ConsumerState<TagEditPage> {
  late final tags = [...widget.tags];
  late var rating = widget.rating;
  final toBeAdded = <String>{};
  final toBeRemoved = <String>{};
  TagEditExpandMode? expandMode;
  final scrollController = ScrollController();
  final splitKey = GlobalKey<SplitState>();

  String? selectedTag;

  final ratingLabels = const [
    'explicit',
    'questionable',
    'sensitive',
    'general',
  ];

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _pop() {
    if (expandMode != null) {
      setState(() {
        expandMode = null;
        splitKey.currentState?.setFractions(const [0.5, 0.5]);
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final booru =
        ref.watch(booruFactoryProvider).create(type: config.booruType);
    final aiTagSupport = booru?.hasAiTagSupported(config.url);

    return PopScope(
      canPop: expandMode == null,
      onPopInvoked: (didPop) {
        if (didPop) return;

        _pop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: isMobilePlatform() && expandMode != null,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _pop,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            TextButton(
              onPressed: (toBeAdded.isNotEmpty ||
                      toBeRemoved.isNotEmpty ||
                      rating != widget.rating)
                  ? () {
                      ref
                          .read(
                              danbooruTagListProvider(ref.readConfig).notifier)
                          .setTags(
                            widget.postId,
                            addedTags: toBeAdded.toList(),
                            removedTags: toBeRemoved.toList(),
                            rating: rating != widget.rating ? rating : null,
                          );
                      context.pop();
                    }
                  : null,
              child: const Text('Submit'),
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Screen.of(context).size == ScreenSize.small
              ? Column(
                  children: [
                    Expanded(
                      child: _buildSplit(context, config),
                    ),
                    _buildMode(context, aiTagSupport ?? false),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildImage(),
                    ),
                    const VerticalDivider(
                      width: 4,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      width: min(
                        MediaQuery.of(context).size.width * 0.4,
                        380,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: TagEditRatingSelectorSection(
                                    rating: rating,
                                    onChanged: (value) {
                                      setState(() {
                                        rating = value;
                                      });
                                    },
                                  ),
                                ),
                                const SliverSizedBox(height: 8),
                                SliverToBoxAdapter(
                                  child: _buildTagListSection(),
                                ),
                              ],
                            ),
                          ),
                          _buildMode(context, aiTagSupport ?? false)
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight > 80
          ? BooruImage(
              borderRadius: BorderRadius.zero,
              imageUrl: widget.imageUrl,
              aspectRatio: widget.aspectRatio,
              fit: BoxFit.contain,
            )
          : SizedBox(
              height: constraints.maxHeight,
            ),
    );
  }

  Widget _buildSplit(BuildContext context, BooruConfig config) {
    return Theme(
      data: context.theme.copyWith(
        focusColor: context.colorScheme.primary,
      ),
      child: Split(
        key: splitKey,
        axis: Axis.vertical,
        initialFractions: const [0.5, 0.5],
        minSizes: const [4, 100],
        ignoreFractionChange: true,
        children: [
          Column(
            children: [
              Expanded(
                child: _buildImage(),
              ),
              const Divider(
                thickness: 1,
                height: 4,
              ),
            ],
          ),
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: TagEditRatingSelectorSection(
                  rating: rating,
                  onChanged: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
              ),
              const SliverSizedBox(height: 8),
              SliverToBoxAdapter(
                child: _buildTagListSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagListSection() {
    return TagEditTagListSection(
      tags: tags.toList(),
      toBeAdded: toBeAdded.toSet(),
      toBeRemoved: toBeRemoved.toSet(),
      initialTags: widget.tags,
      onDeleted: (tag) {
        _removeTag(tag);
      },
      onTagTap: (tag) {
        setState(() {
          selectedTag = tag;
          expandMode = TagEditExpandMode.related;
          splitKey.currentState?.setFractions(const [0.9, 0.1]);
        });
      },
    );
  }

  Widget _buildMode(BuildContext context, bool aiTagSupport) =>
      switch (expandMode) {
        TagEditExpandMode.favorite => Container(
            height: 280,
            color: context.colorScheme.secondaryContainer,
            child: Column(
              children: [
                _buildAppSheetAppbar('Favorites'),
                Expanded(
                  child: TagEditFavoriteView(
                    onRemoved: (tag) {
                      _removeTag(tag);
                    },
                    onAdded: (tag) {
                      _addTag(tag);
                    },
                    isSelected: (tag) => tags.contains(tag),
                  ),
                ),
              ],
            ),
          ),
        TagEditExpandMode.related => Container(
            height: 280,
            color: context.colorScheme.secondaryContainer,
            child: Column(
              children: [
                _buildAppSheetAppbar('Related'),
                Expanded(
                  child: TagEditWikiView(
                    tag: selectedTag,
                    onRemoved: (tag) {
                      _removeTag(tag);
                    },
                    onAdded: (tag) {
                      _addTag(tag);
                    },
                    isSelected: (tag) => tags.contains(tag),
                  ),
                ),
              ],
            ),
          ),
        TagEditExpandMode.aiTag => Container(
            height: 280,
            color: context.colorScheme.secondaryContainer,
            child: Column(
              children: [
                _buildAppSheetAppbar('Suggested'),
                Expanded(
                  child: TagEditAITagView(
                    postId: widget.postId,
                    onRemoved: (tag) {
                      _removeTag(tag);
                    },
                    onAdded: (tag) {
                      _addTag(tag);
                    },
                    isSelected: (tag) => tags.contains(tag),
                  ),
                ),
              ],
            ),
          ),
        null => Container(
            margin: const EdgeInsets.only(left: 8, bottom: 20, top: 8),
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    backgroundColor: context.colorScheme.surfaceVariant,
                  ),
                  onPressed: () {
                    goToQuickSearchPage(
                      context,
                      ref: ref,
                      onSelected: (tag) {
                        _addTag(tag.value);
                      },
                    );
                  },
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    backgroundColor: context.colorScheme.surfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      expandMode = TagEditExpandMode.favorite;
                      splitKey.currentState?.setFractions(const [0.9, 0.1]);
                    });
                  },
                  child: Text(
                    'Favorites',
                    style: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    backgroundColor: context.colorScheme.surfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      expandMode = TagEditExpandMode.related;
                      splitKey.currentState?.setFractions(const [0.9, 0.1]);
                    });
                  },
                  child: Text(
                    'Related',
                    style: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (aiTagSupport) ...[
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      backgroundColor: context.colorScheme.surfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        expandMode = TagEditExpandMode.aiTag;
                        splitKey.currentState?.setFractions(const [0.9, 0.1]);
                      });
                    },
                    child: Text(
                      'Suggested',
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      };

  Widget _buildAppSheetAppbar(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceVariant,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  setState(() {
                    expandMode = null;
                    splitKey.currentState?.setFractions(const [0.5, 0.5]);
                  });
                },
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _removeTag(String tag) {
    setState(() {
      if (toBeAdded.contains(tag)) {
        tags.remove(tag);
        toBeAdded.remove(tag);
      } else {
        tags.remove(tag);
        toBeRemoved.add(tag);
      }
    });
  }

  void _addTag(String tag) {
    setState(() {
      if (tags.contains(tag)) return;
      if (toBeAdded.contains(tag)) return;
      tags.add(tag);
      toBeAdded.add(tag);
      // Hacky way to scroll to the end of the list, somehow if it is currently on top, it won't scroll to last item
      final offset =
          scrollController.offset == scrollController.position.maxScrollExtent
              ? 0
              : scrollController.position.maxScrollExtent / tags.length;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (!mounted || !scrollController.hasClients) return;

          scrollController.animateTo(
            scrollController.position.maxScrollExtent + offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        },
      );

      Future.delayed(
        const Duration(milliseconds: 200),
        () {},
      );
    });
  }
}

class TagEditRatingSelectorSection extends ConsumerWidget {
  const TagEditRatingSelectorSection({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final Rating rating;
  final void Function(Rating rating) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!config.hasStrictSFW)
                  IconButton(
                    splashRadius: 20,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => launchExternalUrlString(_kHowToRateUrl),
                    icon: const FaIcon(
                      FontAwesomeIcons.circleQuestion,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          Center(
            child: BooruSegmentedButton(
              segments: {
                for (final rating
                    in Rating.values.where((e) => e != Rating.unknown))
                  rating: constraints.maxWidth > 350
                      ? rating.name.sentenceCase
                      : rating.name.sentenceCase
                          .getFirstCharacter()
                          .toUpperCase(),
              },
              initialValue: rating,
              onChanged: onChanged,
              fixedWidth: constraints.maxWidth < 350 ? 36 : null,
            ),
          ),
        ],
      ),
    );
  }
}

final tagEditTagFilterModeProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final tagEditCurrentFilterProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final tagEditFilteredListProvider =
    Provider.autoDispose.family<List<String>, List<String>>((ref, tags) {
  final filter = ref.watch(tagEditCurrentFilterProvider);

  if (filter.isEmpty) return tags;

  return tags.where((tag) => tag.contains(filter)).toList();
});

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

  final List<String> initialTags;
  final List<String> tags;
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Divider(
          thickness: 1,
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: SizedBox(
                                height: 36,
                                child: BooruSearchBar(
                                  autofocus: true,
                                  hintText: 'Filter...',
                                  onChanged: (value) => ref
                                      .read(
                                          tagEditCurrentFilterProvider.notifier)
                                      .state = value,
                                ),
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
                                Icons.check,
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
                        Icons.filter_list,
                      ),
                    ),
              if (!filterOn) const Spacer(),
              if (!filterOn)
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'fetch_category',
                      child: Text('Fetch tag category'),
                    ),
                  ],
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
            itemBuilder: (_, index) {
              final colors = _getColors(filtered[index], context, ref);

              return TagEditTagTile(
                title: Text(
                  filtered[index].replaceAll('_', ' '),
                  style: TextStyle(
                    color: context.themeMode.isLight
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
      ref.invalidate(danbooruTagEditColorProvider(tag.rawName));
    }
  }

  ChipColors? _getColors(String tag, BuildContext context, WidgetRef ref) {
    final colors = ref.watch(danbooruTagEditColorProvider(tag)).maybeWhen(
          data: (color) => color != null && color != Colors.white
              ? generateChipColorsFromColorScheme(
                  color,
                  ref.watch(settingsProvider),
                  context.colorScheme,
                )
              : null,
          orElse: () => null,
        );

    return colors;
  }
}

class TagEditTagTile extends StatefulWidget {
  const TagEditTagTile({
    super.key,
    required this.onTap,
    required this.filtered,
    required this.onDeleted,
    required this.title,
  });

  final void Function() onTap;
  final List<String> filtered;
  final void Function() onDeleted;
  final Widget title;

  @override
  State<TagEditTagTile> createState() => _TagEditTagTileState();
}

class _TagEditTagTileState extends State<TagEditTagTile> {
  var hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          hover = false;
        });
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.title,
              ),
              if (!isMobilePlatform() && !hover)
                const SizedBox(
                  height: 32,
                )
              else
                IconButton(
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onDeleted,
                  icon: Icon(
                    Icons.close,
                    size: isDesktopPlatform() ? 16 : 20,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
