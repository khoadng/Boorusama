// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => ConditionalRenderWidget(
          condition: _shouldShowSearchButton(
            state.displayState,
            tags,
          ),
          childBuilder: (context) => FloatingActionButton(
            onPressed: () =>
                context.read<SearchBloc>().add(const SearchRequested()),
            heroTag: null,
            child: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

bool _shouldShowSearchButton(
  DisplayState displayState,
  List<TagSearchItem> selectedTags,
) {
  if (displayState == DisplayState.options) {
    return selectedTags.isNotEmpty;
  }
  if (displayState == DisplayState.suggestion) return false;

  return false;
}
