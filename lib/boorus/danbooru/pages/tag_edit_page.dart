// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

enum TagEditExpandMode {
  favorite,
  related,
  aiTag,
}

const _kHowToRateUrl = 'https://danbooru.donmai.us/wiki_pages/howto:rate';

final danbooruTagEditColorProvider =
    FutureProvider.autoDispose.family<ChipColors?, String>((ref, tag) async {
  final config = ref.watchConfig;
  final settings = ref.watch(settingsProvider);
  final tagTypeStore = ref.watch(booruTagTypeStoreProvider);
  final tagType = await tagTypeStore.get(config.booruType, tag);

  final color = ref
      .watch(booruBuilderProvider)
      ?.tagColorBuilder(settings.themeMode, tagType);

  return color != null && color != Colors.white
      ? generateChipColors(color, settings.themeMode)
      : null;
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
        appBar: AppBar(
          title: const Text('Edit'),
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
        body: Column(
          children: [
            Expanded(
              child: _buildSplit(context),
            ),
            _buildMode(context, aiTagSupport ?? false),
          ],
        ),
      ),
    );
  }

  Widget _buildSplit(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        focusColor: context.colorScheme.primary,
      ),
      child: Split(
        axis: Axis.vertical,
        initialFractions: const [0.3, 0.7],
        minSizes: const [120, 100],
        ignoreFractionChange: true,
        children: [
          Column(
            children: [
              Expanded(
                child: BooruImage(
                  borderRadius: BorderRadius.zero,
                  imageUrl: widget.imageUrl,
                  aspectRatio: widget.aspectRatio,
                  fit: BoxFit.contain,
                ),
              ),
              const Divider(
                thickness: 2,
                height: 4,
              ),
            ],
          ),
          CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        'Rating',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        splashRadius: 20,
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            launchExternalUrlString(_kHowToRateUrl),
                        icon: const FaIcon(
                          FontAwesomeIcons.circleQuestion,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ToggleSwitch(
                    dividerColor: Colors.black,
                    changeOnTap: false,
                    initialLabelIndex: ratingLabels.indexOf(rating.name),
                    minWidth: 75,
                    minHeight: 30,
                    cornerRadius: 5,
                    customWidths: const [70, 120, 80, 75],
                    labels: ratingLabels.map((e) => e.sentenceCase).toList(),
                    activeBgColor: [context.colorScheme.primary],
                    inactiveBgColor: context.colorScheme.background,
                    borderWidth: 1,
                    borderColor: [context.theme.hintColor],
                    onToggle: (index) {
                      setState(() {
                        rating = switch (index) {
                          0 => Rating.explicit,
                          1 => Rating.questionable,
                          2 => Rating.sensitive,
                          3 => Rating.general,
                          _ => Rating.unknown,
                        };
                      });
                    },
                  ),
                ),
              ),
              const SliverSizedBox(height: 8),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text:
                              '${widget.tags.length} tag${widget.tags.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.titleLarge,
                          children: [
                            if (toBeAdded.isNotEmpty && toBeRemoved.isNotEmpty)
                              TextSpan(
                                text:
                                    ' (${toBeAdded.length} added, ${toBeRemoved.length} removed)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: context.theme.hintColor,
                                    ),
                              )
                            else if (toBeAdded.isNotEmpty)
                              TextSpan(
                                text: ' (${toBeAdded.length} added)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: context.theme.hintColor,
                                    ),
                              )
                            else if (toBeRemoved.isNotEmpty)
                              TextSpan(
                                text: ' (${toBeRemoved.length} removed)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: context.theme.hintColor,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(
                  thickness: 2,
                ),
              ),
              SliverToBoxAdapter(
                child: Wrap(
                  runSpacing: isMobilePlatform() ? -4 : 8,
                  spacing: 4,
                  children: tags.map((tag) {
                    final colors =
                        ref.watch(danbooruTagEditColorProvider(tag)).maybeWhen(
                              data: (color) => color,
                              orElse: () => null,
                            );
                    final backgroundColor = colors?.backgroundColor;
                    final foregroundColor = colors?.foregroundColor;
                    final borderColor = colors?.borderColor;

                    return RawChip(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                              selectedTag = tag;
                              expandMode = TagEditExpandMode.related;
                            }),
                        deleteIcon: Icon(
                          color: foregroundColor,
                          Icons.close,
                          size: 18,
                        ),
                        side: borderColor != null
                            ? BorderSide(
                                color: borderColor,
                                width: 1,
                              )
                            : null,
                        backgroundColor: backgroundColor,
                        onDeleted: () => _removeTag(tag),
                        label: Text(
                          tag.replaceAll('_', ' '),
                          style: TextStyle(
                            color: foregroundColor,
                            fontWeight: toBeAdded.contains(tag)
                                ? FontWeight.w900
                                : null,
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMode(BuildContext context, bool aiTagSupport) =>
      switch (expandMode) {
        TagEditExpandMode.favorite => Container(
            height: 280,
            color: context.colorScheme.background,
            child: TagEditFavoriteView(
              onRemoved: (tag) {
                _removeTag(tag);
              },
              onAdded: (tag) {
                _addTag(tag);
              },
              onClosed: () {
                setState(() {
                  expandMode = null;
                });
              },
              isSelected: (tag) => tags.contains(tag),
            ),
          ),
        TagEditExpandMode.related => Container(
            height: 280,
            color: context.colorScheme.background,
            child: TagEditWikiView(
              tag: selectedTag,
              onRemoved: (tag) {
                _removeTag(tag);
              },
              onAdded: (tag) {
                _addTag(tag);
              },
              onClosed: () {
                setState(() {
                  expandMode = null;
                  selectedTag = null;
                });
              },
              isSelected: (tag) => tags.contains(tag),
            ),
          ),
        TagEditExpandMode.aiTag => Container(
            height: 280,
            color: context.colorScheme.background,
            child: TagEditAITagView(
              postId: widget.postId,
              onRemoved: (tag) {
                _removeTag(tag);
              },
              onAdded: (tag) {
                _addTag(tag);
              },
              onClosed: () {
                setState(() {
                  expandMode = null;
                });
              },
              isSelected: (tag) => tags.contains(tag),
            ),
          ),
        null => Container(
            margin: const EdgeInsets.only(left: 20, bottom: 20, top: 8),
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.cardColor,
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
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.cardColor,
                  ),
                  onPressed: () {
                    setState(() {
                      expandMode = TagEditExpandMode.favorite;
                    });
                  },
                  child: const Text('Favorites'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.theme.cardColor,
                  ),
                  onPressed: () {
                    setState(() {
                      expandMode = TagEditExpandMode.related;
                    });
                  },
                  child: const Text('Related'),
                ),
                if (aiTagSupport) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.theme.cardColor,
                    ),
                    onPressed: () {
                      setState(() {
                        expandMode = TagEditExpandMode.aiTag;
                      });
                    },
                    child: const Text('Suggested'),
                  ),
                ],
              ],
            ),
          ),
      };

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

class TagEditFavoriteView extends ConsumerStatefulWidget {
  const TagEditFavoriteView({
    super.key,
    required this.onRemoved,
    required this.onAdded,
    required this.onClosed,
    required this.isSelected,
  });

  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;
  final void Function() onClosed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditFavoriteViewState();
}

class _TagEditFavoriteViewState extends ConsumerState<TagEditFavoriteView> {
  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(favoriteTagsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Favorite tags'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: widget.onClosed,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
      backgroundColor: context.colorScheme.background,
      body: Builder(
        builder: (context) {
          return Wrap(
            spacing: 4,
            children: tags.map((tag) {
              final selected = widget.isSelected(tag.name);

              return RawChip(
                selected: selected,
                showCheckmark: true,
                checkmarkColor:
                    context.themeMode.isDark ? Colors.black : Colors.white,
                visualDensity: VisualDensity.compact,
                onSelected: (value) => value
                    ? widget.onAdded(tag.name)
                    : widget.onRemoved(tag.name),
                label: Text(
                  tag.name.replaceUnderscoreWithSpace(),
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TagEditWikiView extends ConsumerStatefulWidget {
  const TagEditWikiView({
    super.key,
    required this.onRemoved,
    required this.onAdded,
    required this.onClosed,
    required this.isSelected,
    required this.tag,
  });

  final String? tag;
  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;
  final void Function() onClosed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditzwikiViewState();
}

class _TagEditzwikiViewState extends ConsumerState<TagEditWikiView> {
  final relatedTabs = const [
    'all',
    'wiki',
  ];
  var selectTab = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Related tags'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: widget.onClosed,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
      backgroundColor: context.colorScheme.background,
      body: widget.tag.toOption().fold(
            () => const Center(
              child: Text(
                'Select a tag to view related tags',
              ),
            ),
            (tag) => SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: ToggleSwitch(
                      dividerColor: Colors.black,
                      changeOnTap: false,
                      initialLabelIndex: relatedTabs.indexOf(selectTab),
                      minWidth: 75,
                      minHeight: 30,
                      cornerRadius: 5,
                      customWidths: const [60, 70],
                      labels: relatedTabs.map((e) => e.sentenceCase).toList(),
                      activeBgColor: [context.colorScheme.primary],
                      inactiveBgColor: context.colorScheme.background,
                      borderWidth: 1,
                      borderColor: [context.theme.hintColor],
                      onToggle: (index) {
                        setState(() {
                          selectTab = switch (index) {
                            1 => 'wiki',
                            _ => 'all',
                          };
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  switch (selectTab) {
                    'wiki' =>
                      ref.watch(danbooruWikiTagsProvider(tag)).maybeWhen(
                          data: (data) => data.isNotEmpty
                              ? _RelatedTagChips(
                                  tags: data,
                                  isSelected: widget.isSelected,
                                  onAdded: widget.onAdded,
                                  onRemoved: widget.onRemoved,
                                )
                              : const Center(child: Text('No tags found')),
                          orElse: () => const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )),
                    _ => ref.watch(danbooruRelatedTagsProvider(tag)).maybeWhen(
                        data: (data) => _RelatedTagChips(
                              tags: data,
                              isSelected: widget.isSelected,
                              onAdded: widget.onAdded,
                              onRemoved: widget.onRemoved,
                            ),
                        orElse: () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )),
                  },
                ],
              ),
            ),
          ),
    );
  }
}

class _RelatedTagChips extends ConsumerWidget {
  const _RelatedTagChips({
    required this.tags,
    required this.isSelected,
    required this.onAdded,
    required this.onRemoved,
  });

  final List<Tag> tags;
  final bool Function(String tag) isSelected;
  final void Function(String tag) onAdded;
  final void Function(String tag) onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 4,
      children: tags.map((tag) {
        final selected = isSelected(tag.name);
        final colors = generateChipColors(
            ref.getTagColor(context, tag.category.name), context.themeMode);

        return RawChip(
          selected: selected,
          showCheckmark: true,
          checkmarkColor: colors.foregroundColor,
          visualDensity: VisualDensity.compact,
          selectedColor: colors.backgroundColor,
          backgroundColor: selected ? colors.backgroundColor : null,
          side: selected
              ? BorderSide(
                  width: 2,
                  color: colors.borderColor,
                )
              : null,
          onSelected: (value) =>
              value ? onAdded(tag.name) : onRemoved(tag.name),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.screenWidth * 0.8,
            ),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: tag.name.replaceUnderscoreWithSpace(),
                style: TextStyle(
                  color: colors.foregroundColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '  ${NumberFormat.compact().format(tag.postCount)}',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TagEditAITagView extends ConsumerStatefulWidget {
  const TagEditAITagView({
    super.key,
    required this.onRemoved,
    required this.onAdded,
    required this.onClosed,
    required this.isSelected,
    required this.postId,
  });

  final int postId;
  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;
  final void Function() onClosed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditAITagViewState();
}

class _TagEditAITagViewState extends ConsumerState<TagEditAITagView> {
  @override
  Widget build(BuildContext context) {
    final tagAsync = ref.watch(danbooruAITagsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Suggested tags'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: widget.onClosed,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ),
      backgroundColor: context.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            WarningContainer(contentBuilder: (context) {
              return const Text(
                  'The suggested tags are generated by AI, please check them carefully before submitting.');
            }),
            tagAsync.maybeWhen(
              data: (tags) => Wrap(
                spacing: 4,
                children: tags.map((d) {
                  final tag = d.tag;
                  final colors = generateChipColors(
                      ref.getTagColor(context, tag.category.name),
                      context.themeMode);
                  final selected = widget.isSelected(tag.name);

                  return RawChip(
                    selected: selected,
                    showCheckmark: true,
                    checkmarkColor: colors.foregroundColor,
                    visualDensity: VisualDensity.compact,
                    selectedColor: colors.backgroundColor,
                    backgroundColor: selected ? colors.backgroundColor : null,
                    side: selected
                        ? BorderSide(
                            width: 2,
                            color: colors.borderColor,
                          )
                        : null,
                    onSelected: (value) => value
                        ? widget.onAdded(tag.name)
                        : widget.onRemoved(tag.name),
                    label: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.screenWidth * 0.8,
                      ),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: tag.name.replaceUnderscoreWithSpace(),
                          style: TextStyle(
                            color: colors.foregroundColor,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '  ${d.score}%',
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              orElse: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
