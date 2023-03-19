// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';

class BlacklistedTagsSearchPage extends StatefulWidget {
  const BlacklistedTagsSearchPage({
    super.key,
    required this.onSelectedDone,
    this.initialTags,
  });

  final void Function(List<TagSearchItem> tags) onSelectedDone;
  final List<String>? initialTags;

  @override
  State<BlacklistedTagsSearchPage> createState() =>
      _BlacklistedTagsSearchPageState();
}

class _BlacklistedTagsSearchPageState extends State<BlacklistedTagsSearchPage> {
  final queryEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialTags != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TagSearchBloc>()
            .add(TagSearchNewRawStringTagsSelected(widget.initialTags!));
      });
    }

    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: queryEditingController.text.length),
      );
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.query.isEmpty,
          listener: (context, state) => queryEditingController.clear(),
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.isDone,
          listener: (context, state) {
            if (state.selectedTags.isNotEmpty) {
              widget.onSelectedDone(state.selectedTags);
            }
          },
        ),
      ],
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              context.read<TagSearchBloc>().add(const TagSearchDone()),
          heroTag: null,
          child: const FaIcon(FontAwesomeIcons.check),
        ),
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) => SearchBar(
              autofocus: true,
              queryEditingController: queryEditingController,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              trailing: state.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context
                          .read<TagSearchBloc>()
                          .add(const TagSearchCleared()),
                    )
                  : null,
              onChanged: (value) =>
                  context.read<TagSearchBloc>().add(TagSearchChanged(value)),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (state.selectedTags.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      height: 35,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.selectedTags.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildSelectedTagChip(
                              state.selectedTags[index],
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
                      tags: state.suggestionTags,
                      currentQuery: state.query,
                      onItemTap: (tag) => context
                          .read<TagSearchBloc>()
                          .add(TagSearchNewTagSelected(tag)),
                    ),
                  ),
                ],
              );
            },
          ),
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
        onDeleted: () => context
            .read<TagSearchBloc>()
            .add(TagSearchSelectedTagRemoved(tagSearchItem)),
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
          onDeleted: () => context
              .read<TagSearchBloc>()
              .add(TagSearchSelectedTagRemoved(tagSearchItem)),
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
