// Flutter imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/string.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme_utils.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TagEditPage extends ConsumerStatefulWidget {
  const TagEditPage({
    super.key,
    required this.postId,
    required this.tags,
    required this.rating,
  });

  final int postId;
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

  final ratingLabels = const [
    'explicit',
    'questionable',
    'sensitive',
    'general',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit tags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: WarningContainer(
                    contentBuilder: (context) => const Text(
                      'Before editing, read the how to tag guide.',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Rating',
                      style: Theme.of(context).textTheme.titleLarge,
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
                        Text(
                          'Tags',
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
                        title: Text(
                          tag.replaceAll('_', ' '),
                          style: TextStyle(
                            color: toBeRemoved.contains(tag)
                                ? context.theme.hintColor
                                : null,
                            decoration: toBeRemoved.contains(tag)
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: toBeAdded.contains(tag)
                                ? FontWeight.w900
                                : null,
                          ),
                        ),
                        trailing: toBeRemoved.contains(tag)
                            ? IconButton(
                                onPressed: () => setState(() {
                                  toBeRemoved.remove(tag);
                                }),
                                icon: const Icon(Icons.restart_alt),
                              )
                            : IconButton(
                                onPressed: () => setState(() {
                                  if (toBeAdded.contains(tag)) {
                                    tags.remove(tag);
                                    toBeAdded.remove(tag);
                                  } else {
                                    toBeRemoved.add(tag);
                                  }
                                }),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: BooruSearchBar(
                    enabled: false,
                    hintText: 'Add tag',
                    onTap: () {
                      goToQuickSearchPage(
                        context,
                        ref: ref,
                        onSelected: (tag) => setState(() {
                          tags.add(tag.value);
                          toBeAdded.add(tag.value);
                        }),
                      );
                    },
                  ),
                ),
                if (toBeAdded.isNotEmpty ||
                    toBeRemoved.isNotEmpty ||
                    rating != widget.rating)
                  IconButton(
                    onPressed: () {
                      ref
                          .read(
                              danbooruTagListProvider(ref.readConfig).notifier)
                          .setTags(
                        widget.postId,
                        [
                          ...toBeAdded,
                          ...toBeRemoved.map((e) => '-$e'),
                          if (rating != widget.rating) 'rating:${rating.name}',
                        ],
                      );
                      context.pop();
                    },
                    icon: const Icon(Icons.save),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
