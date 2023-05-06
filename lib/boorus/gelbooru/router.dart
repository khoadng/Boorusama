// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/artists/gelbooru_artist_page.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/boorus/gelbooru/ui/search/gelbooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/tags.dart';
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
  final booru = context.read<CurrentBooruBloc>().state.booru!;

  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    child: GelbooruProvider.of(
      context,
      booru: booru,
      builder: (gcontext) {
        final tagInfo = gcontext.read<TagInfo>();
        final searchHistoryBloc = SearchHistoryBloc(
          searchHistoryRepository: gcontext.read<SearchHistoryRepository>(),
        )..add(const SearchHistoryFetched());
        final favoriteTagBloc = gcontext.read<FavoriteTagBloc>()
          ..add(const FavoriteTagFetched());

        final searchHistorySuggestions = SearchHistorySuggestionsBloc(
          searchHistoryRepository: context.read<SearchHistoryRepository>(),
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: searchHistoryBloc),
            BlocProvider.value(value: favoriteTagBloc),
            BlocProvider.value(value: searchHistorySuggestions),
          ],
          child: CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                selectedTagsProvider.overrideWith(SelectedTagsNotifier.new)
              ],
              child: GelbooruSearchPage(
                metatags: tagInfo.metatags,
                metatagHighlightColor: Theme.of(context).colorScheme.primary,
                initialQuery: tag,
              ),
            ),
          ),
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
