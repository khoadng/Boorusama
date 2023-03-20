// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/application/search_history/search_history.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/searches/searches.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

class SearchPageProvider extends StatelessWidget {
  const SearchPageProvider({
    super.key,
    required this.tagInfo,
    required this.autocompleteRepo,
    required this.postRepo,
    required this.blacklistRepo,
    required this.favRepo,
    required this.accountRepo,
    required this.postVoteRepo,
    required this.poolRepo,
    required this.previewPreloader,
    required this.searchHistoryRepo,
    required this.relatedTagRepo,
    required this.favTagBloc,
    required this.themeBloc,
    required this.postCountRepo,
    required this.builder,
    this.initialQuery,
    required this.trendingTagCubit,
    required this.authenticationCubit,
  });

  final TagInfo tagInfo;
  final AutocompleteRepository autocompleteRepo;
  final DanbooruPostRepository postRepo;
  final BlacklistedTagsRepository blacklistRepo;
  final FavoritePostRepository favRepo;
  final AccountRepository accountRepo;
  final PostVoteRepository postVoteRepo;
  final PoolRepository poolRepo;
  final PostPreviewPreloader previewPreloader;
  final SearchHistoryRepository searchHistoryRepo;
  final RelatedTagRepository relatedTagRepo;
  final FavoriteTagBloc favTagBloc;
  final ThemeBloc themeBloc;
  final TrendingTagCubit trendingTagCubit;
  final PostCountRepository postCountRepo;
  final AuthenticationCubit authenticationCubit;
  final Widget Function(BuildContext context, Settings settings) builder;

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    final booru = context.select((CurrentBooruBloc bloc) => bloc.state.booru);
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    final tagSearchBloc = TagSearchBloc(
      tagInfo: tagInfo,
      autocompleteRepository: autocompleteRepo,
    );

    final currentUserBooruRepository =
        context.read<CurrentUserBooruRepository>();

    final postBloc = PostBloc(
      postRepository: postRepo,
      blacklistedTagsRepository: blacklistRepo,
      favoritePostRepository: favRepo,
      postVoteRepository: postVoteRepo,
      poolRepository: poolRepo,
      previewPreloader: previewPreloader,
      pagination: settings.contentOrganizationCategory ==
          ContentOrganizationCategory.pagination,
      postsPerPage: settings.postsPerPage,
      currentUserBooruRepository: currentUserBooruRepository,
    );

    final searchHistoryCubit = SearchHistoryBloc(
      searchHistoryRepository: searchHistoryRepo,
    );
    final relatedTagBloc = RelatedTagBloc(
      relatedTagRepository: relatedTagRepo,
    );
    final searchHistorySuggestions = SearchHistorySuggestionsBloc(
      searchHistoryRepository: searchHistoryRepo,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: searchHistoryCubit),
        BlocProvider.value(value: authenticationCubit),
        BlocProvider.value(value: trendingTagCubit),
        BlocProvider.value(
          value: favTagBloc..add(const FavoriteTagFetched()),
        ),
        BlocProvider.value(value: postBloc),
        BlocProvider.value(value: themeBloc),
        BlocProvider.value(value: searchHistorySuggestions),
        BlocProvider(
          create: (context) => SearchBloc(
            initial: DisplayState.options,
            metatags: tagInfo.metatags,
            tagSearchBloc: tagSearchBloc,
            searchHistoryBloc: searchHistoryCubit,
            relatedTagBloc: relatedTagBloc,
            searchHistorySuggestionsBloc: searchHistorySuggestions,
            postBloc: postBloc,
            postCountRepository: postCountRepo,
            initialQuery: initialQuery,
            booruType: booru?.booruType ?? BooruType.safebooru,
          ),
        ),
        BlocProvider.value(value: relatedTagBloc),
      ],
      child: CustomContextMenuOverlay(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return builder(context, state.settings);
          },
        ),
      ),
    );
  }
}
