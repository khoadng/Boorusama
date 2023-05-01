// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/search/gelbooru_search_bloc.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/artists/gelbooru_artist_page.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/boorus/gelbooru/ui/search/gelbooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

void goToGelbooruPostDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  Navigator.of(context).push(GelbooruPostDetailPage.routeOf(
    context,
    posts: posts,
    initialIndex: initialIndex,
    scrollController: scrollController,
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

                final searchBloc = GelbooruSearchBloc(
                  initial: DisplayState.options,
                  tagSearchBloc: tagSearchBloc,
                  searchHistoryBloc: searchHistoryBloc,
                  searchHistorySuggestionsBloc: searchHistorySuggestions,
                  metatags: gcontext.read<TagInfo>().metatags,
                  booruType: state.booru!.booruType,
                  initialQuery: tag,
                );

                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: searchHistoryBloc),
                    BlocProvider.value(value: favoriteTagBloc),
                    BlocProvider<SearchBloc>.value(value: searchBloc),
                    BlocProvider.value(value: searchHistorySuggestions),
                    BlocProvider.value(value: tagSearchBloc),
                  ],
                  child: CustomContextMenuOverlay(
                    child: GelbooruSearchPage(
                      autoFocusSearchBar: sstate.settings.autoFocusSearchBar,
                      metatags: tagInfo.metatags,
                      metatagHighlightColor:
                          Theme.of(context).colorScheme.primary,
                    ),
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

void goToGelbooruArtistPage(BuildContext context, String artist) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => provideArtistPageDependencies(
      context,
      artist: artist,
      page: GelbooruArtistPage(
        tagName: artist,
      ),
    ),
  ));
}

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return GelbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) {
          return CustomContextMenuOverlay(
            child: page,
          );
        },
      );
    },
  );
}
