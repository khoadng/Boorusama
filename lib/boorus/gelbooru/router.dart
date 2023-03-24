// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_bloc.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_search_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/search/simple_tag_search_view.dart';
import 'ui/gelbooru_post_detail_page.dart';
import 'ui/utils.dart';

void goToGelbooruPostDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialIndex,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocSelector<SettingsCubit, SettingsState, Settings>(
      selector: (state) => state.settings,
      builder: (_, settings) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return GelbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (gcontext) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: gcontext.read<ThemeBloc>()),
                  BlocProvider(create: (_) => SliverPostGridBloc()),
                  BlocProvider(
                    create: (_) => TagBloc(
                      tagRepository: gcontext.read<TagRepository>(),
                    ),
                  ),
                ],
                child: GelbooruPostDetailPage(
                  posts: posts,
                  initialIndex: initialIndex,
                ),
              ),
            );
          },
        );
      },
    ),
  ));
}

void goToGelbooruSearchPage(
  BuildContext context, {
  String? tag,
}) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    child: BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, sstate) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return GelbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (gcontext) {
                final tagInfo = gcontext.read<TagInfo>();
                final searchHistoryBloc = SearchHistoryBloc(
                  searchHistoryRepository:
                      gcontext.read<SearchHistoryRepository>(),
                )..add(const SearchHistoryFetched());
                final favoriteTagBloc = gcontext.read<FavoriteTagBloc>()
                  ..add(const FavoriteTagFetched());

                final tagSearchBloc = TagSearchBloc(
                  tagInfo: gcontext.read<TagInfo>(),
                  autocompleteRepository:
                      gcontext.read<AutocompleteRepository>(),
                );

                final searchHistorySuggestions = SearchHistorySuggestionsBloc(
                  searchHistoryRepository:
                      context.read<SearchHistoryRepository>(),
                );

                final postBloc = GelbooruPostBloc(
                  postRepository: gcontext.read<PostRepository>(),
                );

                final searchBloc = GelbooruSearchBloc(
                  initial: DisplayState.options,
                  tagSearchBloc: tagSearchBloc,
                  searchHistoryBloc: searchHistoryBloc,
                  searchHistorySuggestionsBloc: searchHistorySuggestions,
                  metatags: gcontext.read<TagInfo>().metatags,
                  booruType: state.booru!.booruType,
                  postBloc: postBloc,
                );

                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: searchHistoryBloc),
                    BlocProvider.value(value: favoriteTagBloc),
                    BlocProvider<SearchBloc>.value(value: searchBloc),
                    BlocProvider.value(value: searchHistorySuggestions),
                    BlocProvider.value(value: postBloc),
                  ],
                  child: GelbooruSearchPage(
                    autoFocusSearchBar: sstate.settings.autoFocusSearchBar,
                    metatags: tagInfo.metatags,
                    metatagHighlightColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            );
          },
        );
      },
    ),
  ));
}

void goToGelbooruQuickSearchPage(
  BuildContext context, {
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  required void Function(BuildContext context, AutocompleteData tag) onSelected,
  void Function(BuildContext context, String text)? onSubmitted,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    builder: (_, isMobile) => BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, themeState) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return GelbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (gcontext) => isMobile
                  ? SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      ensureValidTag: ensureValidTag,
                      floatingActionButton: floatingActionButton != null
                          ? (text) => floatingActionButton.call(text)
                          : null,
                      onSelected: (tag) => onSelected(gcontext, tag),
                      textColorBuilder: (tag) => generateAutocompleteTagColor(
                        tag,
                        themeState.theme,
                      ),
                    )
                  : SimpleTagSearchView(
                      onSubmitted: (_, text) =>
                          onSubmitted?.call(context, text),
                      backButton: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      ensureValidTag: ensureValidTag,
                      onSelected: (tag) => onSelected(gcontext, tag),
                      textColorBuilder: (tag) => generateAutocompleteTagColor(
                        tag,
                        themeState.theme,
                      ),
                    ),
            );
          },
        );
      },
    ),
  );
}
