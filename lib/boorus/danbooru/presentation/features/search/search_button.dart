// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchState) => _shouldShowSearchButton(
          searchState.displayState,
          tags,
        )
            ? BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, ss) => BlocListener<SearchHistoryCubit,
                    AsyncLoadState<List<SearchHistory>>>(
                  listenWhen: (previous, current) =>
                      current.status == LoadStatus.success,
                  listener: (context, state) => context
                      .read<SettingsCubit>()
                      .update(
                          ss.settings.copyWith(searchHistories: state.data!)),
                  child: BlocBuilder<TagSearchBloc, TagSearchState>(
                    builder: (context, state) => FloatingActionButton(
                      onPressed: () => _onPress(context, state.selectedTags),
                      heroTag: null,
                      child: const Icon(Icons.search),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _onPress(BuildContext context, List<TagSearchItem> selectedTags) {
    final tags = selectedTags.map((e) => e.toString()).join(' ');
    context.read<SearchBloc>().add(const SearchRequested());
    context.read<PostBloc>().add(PostRefreshed(tag: tags));
    context.read<SearchHistoryCubit>().addHistory(tags);
  }
}

bool _shouldShowSearchButton(
  DisplayState displayState,
  List<TagSearchItem> selectedTags,
) {
  if (displayState == DisplayState.options) {
    if (selectedTags.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
  if (displayState == DisplayState.suggestion) return false;
  return false;
}
