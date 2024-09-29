// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class BlacklistedTagsViewScaffold extends ConsumerWidget {
  const BlacklistedTagsViewScaffold({
    super.key,
    required this.tags,
    required this.onRemoveTag,
    required this.onEditTap,
    required this.onAddTag,
    required this.title,
    required this.actions,
  });

  final String title;
  final List<Widget> actions;
  final List<String>? tags;
  final void Function(String tag) onRemoveTag;
  final void Function(String oldTag, String newTag) onEditTap;
  final void Function(String tag) onAddTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              goToBlacklistedTagsSearchPage(
                context,
                onSelectDone: (tagItems, currentQuery) {
                  final tagString = _joinTags(tagItems, currentQuery);

                  onAddTag(tagString);
                  context.navigator.pop();
                },
              );
            },
            icon: const Icon(Symbols.add),
          ),
          ...actions,
        ],
      ),
      body: SafeArea(
        child: BlacklistedTagList(
          tags: tags,
          onRemoveTag: onRemoveTag,
          onEditTap: onEditTap,
        ),
      ),
    );
  }
}

class BlacklistedTagList extends StatelessWidget {
  const BlacklistedTagList({
    super.key,
    required this.tags,
    required this.onRemoveTag,
    required this.onEditTap,
  });

  final void Function(String tag) onRemoveTag;
  final void Function(String oldTag, String newTag) onEditTap;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    return tags.toOption().fold(
          () => const Center(child: CircularProgressIndicator()),
          (tags) => tags.isNotEmpty
              ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: WarningContainer(
                        title: 'Limitation',
                        contentBuilder: (context) => AppHtml(
                          data: 'blacklisted_tags.limitation_notice'.tr(),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tag = tags[index];

                          return BlacklistedTagTile(
                            tag: tag,
                            onRemoveTag: (_) => onRemoveTag(tag),
                            onEditTap: () {
                              goToBlacklistedTagsSearchPage(
                                context,
                                initialTags: tag.split(' '),
                                onSelectDone: (tagItems, currentQuery) {
                                  final tagString =
                                      _joinTags(tagItems, currentQuery);

                                  onEditTap(tag, tagString);
                                  context.navigator.pop();
                                },
                              );
                            },
                          );
                        },
                        childCount: tags.length,
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('No blacklisted tags')),
        );
  }
}

String _joinTags(List<TagSearchItem> tagItems, String currentQuery) {
  final tagString = [
    ...tagItems.map((e) => e.toString()),
    if (currentQuery.isNotEmpty) currentQuery,
  ].join(' ');

  return tagString;
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    super.key,
    required this.tag,
    required this.onEditTap,
    required this.onRemoveTag,
  });

  final String tag;
  final VoidCallback onEditTap;
  final void Function(String tag) onRemoveTag;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tag),
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'remove':
              onRemoveTag.call(tag);
              break;
            case 'edit':
              onEditTap.call();
              break;
          }
        },
        itemBuilder: {
          'remove': const Text('blacklisted_tags.remove').tr(),
          'edit': const Text('blacklisted_tags.edit').tr(),
        },
      ),
    );
  }
}
