// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class SimpleTagSearchView extends StatelessWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
  });

  final void Function(AutocompleteData tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TagSearchBloc(
        autocompleteRepository: context.read<AutocompleteRepository>(),
        tagInfo: context.read<TagInfo>(),
      ),
      child: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) {
          final tags =
              state.suggestionTags.where((e) => e.category != null).toList();

          return Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
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
                        onSelected(tag);
                        Navigator.of(context).pop();
                      },
                      currentQuery: state.query,
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text('Type something in search bar'),
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
