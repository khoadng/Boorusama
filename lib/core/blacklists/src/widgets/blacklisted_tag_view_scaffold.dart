// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../routes/local_routes.dart';
import '../types/utils.dart';
import 'blacklisted_tag_list.dart';

class BlacklistedTagsViewScaffold extends ConsumerWidget {
  const BlacklistedTagsViewScaffold({
    required this.tags,
    required this.onRemoveTag,
    required this.onEditTap,
    required this.onAddTag,
    required this.title,
    required this.actions,
    super.key,
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
                  final tagString = joinBlackTagItems(tagItems, currentQuery);

                  onAddTag(tagString);
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
