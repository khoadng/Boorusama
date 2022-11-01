// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
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
          childBuilder: (context) => BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) => FloatingActionButton(
              onPressed: () => _onPress(context, state.selectedTags),
              heroTag: null,
              child: const Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }

  void _onPress(BuildContext context, List<TagSearchItem> selectedTags) {
    final tags = selectedTags.map((e) => e.toString()).join(' ');
    context.read<SearchBloc>().add(const SearchRequested());
    context.read<PostBloc>().add(PostRefreshed(
          tag: tags,
          fetcher: SearchedPostFetcher.fromTags(tags),
        ));
    context.read<SearchHistoryCubit>().addHistory(tags);
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
