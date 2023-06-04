// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/search/filter_operator.dart';
import 'package:boorusama/core/search/selected_tags_notifier.dart';
import 'package:boorusama/core/search/suggestions_notifier.dart';
import 'package:boorusama/core/search/tag_search_item.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';
import 'package:boorusama/core/ui/utils.dart';

final _selectedTagsProvider =
    NotifierProvider.autoDispose<SelectedTagsNotifier, List<TagSearchItem>>(
        SelectedTagsNotifier.new,
        dependencies: [
      tagInfoProvider,
    ]);

final _queryProvider = StateProvider<String>((ref) => '');

final _suggestionsProvider =
    NotifierProvider.autoDispose<SuggestionsNotifier, List<AutocompleteData>>(
  SuggestionsNotifier.new,
  dependencies: [autocompleteRepoProvider],
);

class BlacklistedTagsSearchPage extends ConsumerStatefulWidget {
  const BlacklistedTagsSearchPage({
    super.key,
    required this.onSelectedDone,
    this.initialTags,
  });

  final void Function(List<TagSearchItem> tags) onSelectedDone;
  final List<String>? initialTags;

  @override
  ConsumerState<BlacklistedTagsSearchPage> createState() =>
      _BlacklistedTagsSearchPageState();
}

class _BlacklistedTagsSearchPageState
    extends ConsumerState<BlacklistedTagsSearchPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTags != null) {
        ref.read(_selectedTagsProvider.notifier).addTags(widget.initialTags!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final query = ref.watch(_queryProvider);
    final selectedTags = ref.watch(_selectedTagsProvider);
    final suggestions = ref.watch(_suggestionsProvider);

    ref.listen(
      _queryProvider,
      (previous, next) {
        if (previous != next) {
          ref.read(_suggestionsProvider.notifier).getSuggestions(next);
        }
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onSelectedDone(ref.read(_selectedTagsProvider)),
        heroTag: null,
        child: const FaIcon(FontAwesomeIcons.check),
      ),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.2,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const _SearchBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (selectedTags.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(left: 8),
                height: 35,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedTags.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildSelectedTagChip(
                        selectedTags[index],
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                height: 15,
                thickness: 3,
                indent: 10,
                endIndent: 10,
              ),
            ],
            Expanded(
              child: TagSuggestionItems(
                textColorBuilder: (tag) =>
                    generateAutocompleteTagColor(tag, theme),
                tags: suggestions,
                currentQuery: query,
                onItemTap: (tag) {
                  ref.read(_selectedTagsProvider.notifier).addTag(
                        tag.value,
                        operator: FilterOperator.none,
                      );
                  // clear query
                  ref.read(_queryProvider.notifier).state = '';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTagChip(TagSearchItem tagSearchItem) {
    if (tagSearchItem.operator == FilterOperator.none) {
      return Chip(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        backgroundColor: Colors.grey[800],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        deleteIcon: const Icon(
          FontAwesomeIcons.xmark,
          color: Colors.red,
          size: 15,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        onDeleted: () => ref.read(_selectedTagsProvider.notifier).removeTag(
              tagSearchItem,
            ),
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Text(
            tagSearchItem.tag,
            overflow: TextOverflow.fade,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: Text(
            filterOperatorToStringCharacter(tagSearchItem.operator),
          ),
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          onDeleted: () => ref.read(_selectedTagsProvider.notifier).removeTag(
                tagSearchItem,
              ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Text(
              tagSearchItem.tag,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final TextEditingController queryEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    queryEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_queryProvider);

    ref.listen(
      _queryProvider,
      (previous, next) {
        if (next.isEmpty) {
          queryEditingController.clear();
        }
      },
    );

    return BooruSearchBar(
      autofocus: true,
      queryEditingController: queryEditingController,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      trailing: query.isNotEmpty
          ? IconButton(
              splashRadius: 16,
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(_queryProvider.notifier).state = '',
            )
          : null,
      onChanged: (value) => ref.read(_queryProvider.notifier).state = value,
    );
  }
}
