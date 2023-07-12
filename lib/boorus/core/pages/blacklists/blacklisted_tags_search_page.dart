// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';

class BlacklistedTagsSearchPage extends ConsumerStatefulWidget {
  const BlacklistedTagsSearchPage({
    super.key,
    required this.onSelectedDone,
    this.initialTags,
  });

  final void Function(List<TagSearchItem> tags, String currentQuery)
      onSelectedDone;
  final List<String>? initialTags;

  @override
  ConsumerState<BlacklistedTagsSearchPage> createState() =>
      _BlacklistedTagsSearchPageState();
}

class _BlacklistedTagsSearchPageState
    extends ConsumerState<BlacklistedTagsSearchPage> {
  late final SelectedTagController selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));
  final queryEditingController = TextEditingController();

  var _isSearching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTags != null) {
        selectedTagController.addTags(widget.initialTags!);
      }
    });

    queryEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    ref
        .read(suggestionsProvider.notifier)
        .getSuggestions(queryEditingController.text);

    setState(() {
      _isSearching = queryEditingController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    super.dispose();
    queryEditingController.removeListener(_onTextChanged);
    queryEditingController.dispose();
    selectedTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onSelectedDone(
          selectedTagController.tags,
          queryEditingController.text,
        ),
        heroTag: null,
        child: const FaIcon(FontAwesomeIcons.check),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SearchAppBar(
          queryEditingController: queryEditingController,
          onSubmitted: (value) => selectedTagController.addTag(value),
          onBack: () => context.navigator.pop(),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: selectedTagController,
          builder: (context, selectedTags, __) {
            return Column(
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
                if (_isSearching)
                  Expanded(
                      child: ValueListenableBuilder(
                    valueListenable: queryEditingController,
                    builder: (context, query, __) {
                      final tags = ref.watch(suggestionProvider(query.text));

                      return TagSuggestionItems(
                        textColorBuilder: (tag) =>
                            generateAutocompleteTagColor(tag, theme),
                        tags: tags,
                        currentQuery: sanitizeQuery(query.text),
                        onItemTap: (tag) {
                          selectedTagController.addTag(
                            tag.value,
                            operator: getFilterOperator(query.text),
                          );
                          queryEditingController.clear();
                        },
                      );
                    },
                  )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedTagChip(TagSearchItem tagSearchItem) {
    if (tagSearchItem.operator == FilterOperator.none) {
      return Chip(
        visualDensity: const ShrinkVisualDensity(),
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
        onDeleted: () => selectedTagController.removeTag(tagSearchItem),
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
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: context.colorScheme.secondary,
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
          visualDensity: const ShrinkVisualDensity(),
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
          onDeleted: () => selectedTagController.removeTag(tagSearchItem),
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
