// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../routes/local_routes.dart';
import '../types/utils.dart';
import 'blacklisted_tag_list.dart';
import 'blacklisted_tag_search_bar.dart';

class BlacklistedTagsViewScaffold extends ConsumerStatefulWidget {
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
  ConsumerState<BlacklistedTagsViewScaffold> createState() =>
      _BlacklistedTagsViewScaffoldState();
}

class _BlacklistedTagsViewScaffoldState
    extends ConsumerState<BlacklistedTagsViewScaffold> {
  final _searchController = TextEditingController();
  List<String>? _filteredTags;

  @override
  void initState() {
    super.initState();
    _filteredTags = widget.tags;
  }

  @override
  void didUpdateWidget(BlacklistedTagsViewScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      _filterTags();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTags() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredTags = widget.tags;
      });
      return;
    }

    setState(() {
      _filteredTags = widget.tags
          ?.where((tag) => tag.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              goToBlacklistedTagsSearchPage(
                context,
                onSelectDone: (tagItems, currentQuery) {
                  final tagString = joinBlackTagItems(tagItems, currentQuery);

                  widget.onAddTag(tagString);
                },
              );
            },
            icon: const Icon(Symbols.add),
          ),
          ...widget.actions,
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              children: [
                BlacklistedTagSearchBar(
                  controller: _searchController,
                  onSearch: _filterTags,
                ),
                Expanded(
                  child: BlacklistedTagList(
                    tags: _filteredTags,
                    onRemoveTag: widget.onRemoveTag,
                    onEditTap: widget.onEditTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
