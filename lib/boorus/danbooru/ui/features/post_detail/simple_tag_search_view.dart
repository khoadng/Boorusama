// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class SimpleTagSearchView extends StatelessWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
    this.ensureValidTag = true,
    this.closeOnSelected = true,
    this.floatingActionButton,
  });

  final void Function(AutocompleteData tag) onSelected;
  final bool ensureValidTag;
  final bool closeOnSelected;
  final Widget Function(String currentText)? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TagSearchBloc(
        autocompleteRepository: context.read<AutocompleteRepository>(),
        tagInfo: context.read<TagInfo>(),
      ),
      child: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) {
          final tags = ensureValidTag
              ? state.suggestionTags.where((e) => e.category != null).toList()
              : state.suggestionTags;

          return Scaffold(
            floatingActionButton: floatingActionButton?.call(state.query),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchBar(
                    autofocus: true,
                    onChanged: (value) {
                      context
                          .read<TagSearchBloc>()
                          .add(TagSearchChanged(value));
                    },
                  ),
                ),
                if (tags.isNotEmpty)
                  Expanded(
                    child: TagSuggestionItems(
                      tags: tags,
                      onItemTap: (tag) {
                        if (closeOnSelected) {
                          Navigator.of(context).pop();
                        }
                        onSelected(tag);
                      },
                      currentQuery: state.query,
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
