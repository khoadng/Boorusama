// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/pages/search/simple_tag_search_view.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

enum TagEditExpandMode {
  search,
  favorite,
}

const _kHowToRateUrl = 'https://danbooru.donmai.us/wiki_pages/howto:rate';

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
  late final tags = widget.tags;
  late var rating = widget.rating;
  final toBeAdded = <String>{};
  final toBeRemoved = <String>{};
  TagEditExpandMode? expandMode;
  final scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (expandMode != null) {
          setState(() {
            expandMode = null;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit'),
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
            SizedBox(
              height: 160,
              child: BooruImage(
                borderRadius: BorderRadius.zero,
                imageUrl: widget.imageUrl,
                aspectRatio: widget.aspectRatio,
              ),
            ),
            Expanded(
              child: CustomScrollView(
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
                        labels:
                            ratingLabels.map((e) => e.sentenceCase).toList(),
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
                          Text(
                            '${tags.length} tag${tags.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.titleLarge,
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
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tag = tags[index];
                        return ListTile(
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            tag.replaceAll('_', ' '),
                            style: TextStyle(
                              fontWeight: toBeAdded.contains(tag)
                                  ? FontWeight.w900
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _removeTag(tag),
                            icon: const Icon(Icons.close),
                          ),
                        );
                      },
                      childCount: tags.length,
                    ),
                  )
                ],
              ),
            ),
            switch (expandMode) {
              TagEditExpandMode.search => SizedBox(
                  height: 300,
                  child: SimpleTagSearchView(
                    backButton: IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        setState(() {
                          expandMode = null;
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    closeOnSelected: false,
                    ensureValidTag: false,
                    onSelected: (tag) {
                      _addTag(tag.value);
                      setState(() {
                        expandMode = null;
                      });
                    },
                    textColorBuilder: (tag) =>
                        generateAutocompleteTagColor(tag, context.themeMode),
                  ),
                ),
              TagEditExpandMode.favorite => Container(
                  height: 300,
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
              _ => Container(
                  color: context.colorScheme.background,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            expandMode = TagEditExpandMode.search;
                          });
                        },
                        child: const Text('Search'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            expandMode = TagEditExpandMode.favorite;
                          });
                        },
                        child: const Text('Favorites'),
                      ),
                    ],
                  ),
                ),
            },
          ],
        ),
      ),
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

      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          if (!mounted) return;
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        },
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
