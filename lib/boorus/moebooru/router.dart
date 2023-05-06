// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/boorus/moebooru/ui/search/moebooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

void goToMoebooruSearchPage(
  BuildContext context, {
  String? tag,
}) {
  Navigator.of(context).push(PageTransition(
    type: PageTransitionType.fade,
    child: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (_, state) {
        return MoebooruProvider.of(
          context,
          booru: state.booru!,
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
                    selectedTagsProvider.overrideWith(SelectedTagsNotifier.new),
                  ],
                  child: MoebooruSearchPage(
                    metatags: tagInfo.metatags,
                    metatagHighlightColor:
                        Theme.of(context).colorScheme.primary,
                    initialQuery: tag,
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  ));
}

void goToMoebooruDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialPage,
  AutoScrollController? scrollController,
}) {
  Navigator.push(
    context,
    MoebooruPostDetailsPage.routeOf(
      context,
      posts: posts,
      initialIndex: initialPage,
      scrollController: scrollController,
    ),
  );
}
