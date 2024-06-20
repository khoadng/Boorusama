// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/scrolling.dart';
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

const kHowToRateUrl = 'https://danbooru.donmai.us/wiki_pages/howto:rate';

typedef TagEditColorParams = ({
  AppThemeMode themeMode,
  Color primaryColor,
  String tag,
});

final danbooruTagEditColorProvider = FutureProvider.autoDispose
    .family<Color?, TagEditColorParams>((ref, params) async {
  final tag = params.tag;
  final config = ref.watchConfig;
  final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
  final tagType = await tagTypeStore.get(config.booruType, tag);

  final dynamicColor = ref.watch(enableDynamicColoringSettingsProvider);

  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  final booruBuilder =
      booruBuilderFunc != null ? booruBuilderFunc(config) : null;

  final tagColorBuilder = booruBuilder?.tagColorBuilder;

  if (tagType == null) return null;

  final color = getTagColorCore(
    tagType,
    primaryColor: params.primaryColor,
    themeMode: params.themeMode,
    dynamicColor: dynamicColor,
    color: tagColorBuilder?.call(
      params.themeMode,
      tagType,
    ),
  );

  return color;
});

final selectedTagEditRatingProvider =
    StateProvider.family.autoDispose<Rating?, Rating?>((ref, rating) {
  return rating;
});

class TagEditPage extends ConsumerWidget {
  const TagEditPage({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tags = ref.watch(danbooruTagListProvider(config));
    final initialRating =
        tags.containsKey(post.id) ? tags[post.id]!.rating : post.rating;
    final rating = ref.watch(selectedTagEditRatingProvider(initialRating));

    return TagEditPageInternal(
      postId: post.id,
      imageUrl: post.url720x720,
      aspectRatio: post.aspectRatio ?? 1,
      tags: tags.containsKey(post.id) ? tags[post.id]!.allTags : post.tags,
      submitButtonBuilder: (addedTags, removedTags) => TextButton(
        onPressed: (addedTags.isNotEmpty ||
                removedTags.isNotEmpty ||
                rating != initialRating)
            ? () {
                ref
                    .read(danbooruTagListProvider(ref.readConfig).notifier)
                    .setTags(
                      post.id,
                      addedTags: addedTags,
                      removedTags: removedTags,
                      rating: rating != initialRating ? rating : null,
                    );
                context.pop();
              }
            : null,
        child: const Text('Submit'),
      ),
      ratingSelectorBuilder: () {
        return TagEditRatingSelectorSection(
          rating: initialRating,
          onChanged: (value) {
            ref
                .read(selectedTagEditRatingProvider(initialRating).notifier)
                .state = value;
          },
        );
      },
    );
  }
}

class TagEditPageInternal extends ConsumerStatefulWidget {
  const TagEditPageInternal({
    super.key,
    required this.postId,
    required this.tags,
    required this.imageUrl,
    required this.aspectRatio,
    required this.ratingSelectorBuilder,
    required this.submitButtonBuilder,
    this.sourceBuilder,
  });

  final int postId;
  final String imageUrl;
  final double aspectRatio;
  final Set<String> tags;
  final Widget Function() ratingSelectorBuilder;
  final Widget Function(
    List<String> addedTags,
    List<String> removedTags,
  ) submitButtonBuilder;

  final Widget Function()? sourceBuilder;

  @override
  ConsumerState<TagEditPageInternal> createState() =>
      _TagEditPageInternalState();
}

class _TagEditPageInternalState extends ConsumerState<TagEditPageInternal> {
  late final tags = [...widget.tags];
  final toBeAdded = <String>{};
  final toBeRemoved = <String>{};
  TagEditExpandMode? expandMode;
  final scrollController = ScrollController();
  final splitController = MultiSplitViewController(
    areas: [
      Area(
        id: 'image',
        data: 'image',
        size: 250,
        min: 25,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ],
  );

  String? selectedTag;

  var viewExpanded = false;

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    splitController.dispose();
  }

  void _pop() {
    if (expandMode != null) {
      setState(() {
        expandMode = null;
        _setDefaultSplit();
      });
    } else {
      context.pop();
    }
  }

  void _setDefaultSplit() {
    splitController.areas = [
      Area(
        id: 'image',
        data: 'image',
        size: 250,
        min: 25,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];
  }

  void _setMaxSplit() {
    splitController.areas = [
      Area(
        id: 'image',
        data: 'image',
        size: context.screenHeight * 0.5,
        min: 50 + MediaQuery.viewPaddingOf(context).top,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];
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
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: kPreferredLayout.isMobile && expandMode != null,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _pop,
            icon: const Icon(Symbols.arrow_back),
          ),
          actions: [
            widget.submitButtonBuilder(
              toBeAdded.toList(),
              toBeRemoved.toList(),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: Screen.of(context).size == ScreenSize.small
                ? Column(
                    children: [
                      Expanded(
                        child: _buildSplit(context, config),
                      ),
                      _buildMode(
                        context,
                        aiTagSupport ?? false,
                        constraints.maxHeight,
                      ),
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
                          400,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: CustomScrollView(
                                controller: scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: widget.ratingSelectorBuilder(),
                                  ),
                                  const SliverSizedBox(height: 8),
                                  SliverToBoxAdapter(
                                    child: _buildTagListSection(),
                                  ),
                                ],
                              ),
                            ),
                            _buildMode(
                              context,
                              aiTagSupport ?? false,
                              constraints.maxHeight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight > 80
          ? InteractiveBooruImage(
              useHero: false,
              heroTag: '',
              aspectRatio: widget.aspectRatio,
              imageUrl: widget.imageUrl,
            )
          : SizedBox(
              height: constraints.maxHeight - 4,
            ),
    );
  }

  Widget _buildSplit(BuildContext context, BooruConfig config) {
    return Theme(
      data: context.theme.copyWith(
        focusColor: context.colorScheme.primary,
      ),
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            color: context.colorScheme.onSurface,
            thickness: 4,
            size: 75,
            highlightedSize: 40,
            highlightedColor: context.colorScheme.primary,
          ),
        ),
        child: MultiSplitView(
          axis: Axis.vertical,
          controller: splitController,
          builder: (context, area) => switch (area.data) {
            'image' => Column(
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
            'content' => CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: widget.ratingSelectorBuilder(),
                  ),
                  const SliverSizedBox(height: 8),
                  if (widget.sourceBuilder != null)
                    SliverToBoxAdapter(
                      child: widget.sourceBuilder!(),
                    ),
                  const SliverSizedBox(height: 8),
                  SliverToBoxAdapter(
                    child: _buildTagListSection(),
                  ),
                ],
              ),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }

  Widget _buildTagListSection() {
    return TagEditTagListSection(
      tags: tags.toSet(),
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
          _setMaxSplit();
        });
      },
    );
  }

  Widget _buildMode(
    BuildContext context,
    bool aiTagSupport,
    double maxHeight,
  ) {
    final height =
        viewExpanded ? max(maxHeight - kToolbarHeight - 120.0, 280.0) : 280.0;

    return switch (expandMode) {
      TagEditExpandMode.favorite => Container(
          height: height,
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
          height: height,
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
          height: height,
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
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
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
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                ),
                onPressed: () {
                  setState(() {
                    expandMode = TagEditExpandMode.favorite;
                    _setMaxSplit();
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
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                ),
                onPressed: () {
                  setState(() {
                    expandMode = TagEditExpandMode.related;
                    _setMaxSplit();
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
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: () {
                    setState(() {
                      expandMode = TagEditExpandMode.aiTag;
                      _setMaxSplit();
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
  }

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
          padding: const EdgeInsets.only(right: 4, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  setState(() {
                    viewExpanded = !viewExpanded;
                    if (!viewExpanded) {
                      _setMaxSplit();
                    } else {
                      _setDefaultSplit();
                    }
                  });
                },
                child: !viewExpanded
                    ? const Icon(Symbols.arrow_drop_up)
                    : const Icon(Symbols.arrow_drop_down),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  setState(() {
                    expandMode = null;
                    _setDefaultSplit();
                  });
                },
                child: const Icon(Symbols.close),
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

          scrollController.animateToWithAccessibility(
            scrollController.position.maxScrollExtent + offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            reduceAnimations: ref.read(settingsProvider).reduceAnimations,
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

  final Rating? rating;
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
                    onPressed: () => launchExternalUrlString(kHowToRateUrl),
                    icon: const Icon(
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
                  rating: constraints.maxWidth > 360
                      ? rating.name.sentenceCase
                      : rating.name.sentenceCase
                          .getFirstCharacter()
                          .toUpperCase(),
              },
              initialValue: rating,
              onChanged: onChanged,
              fixedWidth: constraints.maxWidth < 360 ? 36 : null,
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
    Provider.autoDispose.family<List<String>, Set<String>>((ref, tags) {
  final filter = ref.watch(tagEditCurrentFilterProvider);

  if (filter.isEmpty) return tags.toList();

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
      mainAxisAlignment: MainAxisAlignment.start,
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
      final params = (
        themeMode: ref.context.themeMode,
        primaryColor: ref.context.colorScheme.primary,
        tag: tag.rawName,
      );
      ref.invalidate(danbooruTagEditColorProvider(params));
    }
  }

  ChipColors? _getColors(String tag, BuildContext context, WidgetRef ref) {
    final params = (
      themeMode: context.themeMode,
      primaryColor: context.colorScheme.primary,
      tag: tag,
    );

    final colors = ref.watch(danbooruTagEditColorProvider(params)).maybeWhen(
          data: (color) => color != null && color != Colors.white
              ? generateChipColorsFromColorScheme(
                  color,
                  context.colorScheme,
                  context.themeMode,
                  ref.watch(settingsProvider).enableDynamicColoring,
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
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.title,
              ),
              if (!kPreferredLayout.isMobile && !hover)
                const SizedBox(
                  height: 32,
                )
              else
                IconButton(
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onDeleted,
                  icon: Icon(
                    Symbols.close,
                    size: kPreferredLayout.isDesktop ? 16 : 20,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
