// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/artist/artist_commentary_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/user/current_user_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profiles.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/count/post_count_repository_api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/favorites/favorite_group_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/side_bar.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_app.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/settings/setting_repository.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/main.dart';
import 'danbooru_home_page.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBarMenu(
        width: 300,
        popOnSelect: true,
        padding: EdgeInsets.zero,
      ),
      body: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
        builder: (context, state) {
          final booru = state.booru;
          if (booru == null) {
            return const Center(
              child: Text('You havent set any booru yet'),
            );
          }

          switch (booru.booruType) {
            case BooruType.unknown:
              return const Center(
                child: Text('Unknown booru'),
              );
            case BooruType.danbooru:
            case BooruType.safebooru:
            case BooruType.testbooru:
              final dio = context.read<DioProvider>().getDio(booru.url);
              final accountRepo = context.read<AccountRepository>();
              final tagInfo = context.read<TagInfo>();
              final favoriteTagsRepo = context.read<FavoriteTagRepository>();
              final api = Api(dio);

              final settingRepository = context.read<SettingRepository>();
              final searchHistoryRepo = context.read<SearchHistoryRepository>();

              final popularSearchRepo = PopularSearchRepositoryApi(
                accountRepository: accountRepo,
                api: api,
              );

              final tagRepo = TagRepositoryApi(api, accountRepo);

              final artistRepo = ArtistRepositoryApi(api: api);

              final profileRepo = ProfileRepositoryApi(
                accountRepository: accountRepo,
                api: api,
              );

              final postRepo = PostRepositoryApi(api, accountRepo);

              final exploreRepo = ExploreRepositoryApi(
                api: api,
                accountRepository: accountRepo,
                postRepository: postRepo,
              );

              final commentRepo = CommentRepositoryApi(api, accountRepo);

              final userRepo = UserRepositoryApi(
                api,
                accountRepo,
                tagInfo.defaultBlacklistedTags,
              );

              final noteRepo = NoteCacher(
                cache: LruCacher(capacity: 100),
                repo: NoteRepositoryApi(api),
              );

              final favoriteRepo = FavoritePostRepositoryApi(api, accountRepo);

              final artistCommentaryRepo = ArtistCommentaryCacher(
                cache: LruCacher(capacity: 200),
                repo: ArtistCommentaryRepositoryApi(api, accountRepo),
              );

              final poolRepo = PoolRepositoryApi(api, accountRepo);

              final blacklistedTagRepo = BlacklistedTagsRepositoryImpl(
                userRepo,
                accountRepo,
                api,
              );

              final autocompleteRepo = AutocompleteRepositoryApi(
                api: api,
                accountRepository: accountRepo,
              );

              final relatedTagRepo = RelatedTagRepositoryApi(api);

              final commentVoteRepo =
                  CommentVoteApiRepository(api, accountRepo);

              final wikiRepo = WikiRepositoryApi(api);

              final poolDescriptionRepo = PoolDescriptionRepositoryApi(
                dio: dio,
                endpoint: booru.url,
              );

              final postVoteRepo = PostVoteApiRepositoryApi(
                api: api,
                accountRepo: accountRepo,
              );

              final postCountRepo = PostCountRepositoryApi(
                api: api,
                accountRepository: accountRepo,
              );

              final savedSearchRepo =
                  SavedSearchRepositoryApi(api, accountRepo);

              final favoriteGroupRepo = FavoriteGroupRepositoryApi(
                api: api,
                accountRepository: accountRepo,
              );

              final favoritedCubit = FavoritesCubit(postRepository: postRepo);
              final trendingTagCubit = TrendingTagCubit(
                popularSearchRepo,
                booru.booruType == BooruType.safebooru
                    ? tagInfo.r18Tags.toSet()
                    : {},
              )..getTags();
              final profileCubit = ProfileCubit(profileRepository: profileRepo);
              final commentBloc = CommentBloc(
                commentVoteRepository: commentVoteRepo,
                commentRepository: commentRepo,
                accountRepository: accountRepo,
              );
              final artistCommentaryBloc = ArtistCommentaryBloc(
                artistCommentaryRepository: artistCommentaryRepo,
              );
              final accountCubit = AccountCubit(accountRepository: accountRepo)
                ..getCurrentAccount();
              final authenticationCubit = AuthenticationCubit(
                accountRepository: accountRepo,
                profileRepository: profileRepo,
              )..logIn();
              final blacklistedTagsBloc = BlacklistedTagsBloc(
                accountRepository: accountRepo,
                blacklistedTagsRepository: blacklistedTagRepo,
              )..add(const BlacklistedTagRequested());
              final poolOverviewBloc = PoolOverviewBloc()
                ..add(const PoolOverviewChanged(
                  category: PoolCategory.series,
                  order: PoolOrder.latest,
                ));

              final tagBloc = TagBloc(
                tagRepository: TagCacher(
                  cache: LruCacher(capacity: 1000),
                  repo: tagRepo,
                ),
              );

              final artistBloc = ArtistBloc(
                artistRepository: ArtistCacher(
                  repo: artistRepo,
                  cache: LruCacher(capacity: 100),
                ),
              );

              final wikiBloc = WikiBloc(
                wikiRepository: WikiCacher(
                  cache: LruCacher(capacity: 200),
                  repo: wikiRepo,
                ),
              );

              final savedSearchBloc = SavedSearchBloc(
                savedSearchRepository: savedSearchRepo,
              );

              final favoriteTagBloc =
                  FavoriteTagBloc(favoriteTagRepository: favoriteTagsRepo);

              PostBloc create() => PostBloc(
                    postRepository: postRepo,
                    blacklistedTagsRepository: blacklistedTagRepo,
                    favoritePostRepository: favoriteRepo,
                    accountRepository: accountRepo,
                    postVoteRepository: postVoteRepo,
                    poolRepository: poolRepo,
                  );

              final exploreBloc = ExploreBloc(
                exploreRepository: exploreRepo,
                popular: create(),
                hot: create(),
                mostViewed: create(),
              )..add(const ExploreFetched());

              final currentUserBloc = CurrentUserBloc(
                userRepository: userRepo,
                accountRepository: accountRepo,
              )..add(const CurrentUserFetched());

              return MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<TagRepository>.value(value: tagRepo),
                  RepositoryProvider<ProfileRepository>.value(
                    value: profileRepo,
                  ),
                  RepositoryProvider<FavoritePostRepository>.value(
                    value: favoriteRepo,
                  ),
                  RepositoryProvider<AccountRepository>.value(
                    value: accountRepo,
                  ),
                  RepositoryProvider<SettingRepository>.value(
                    value: settingRepository,
                  ),
                  RepositoryProvider<NoteRepository>.value(value: noteRepo),
                  RepositoryProvider<PostRepository>.value(value: postRepo),
                  RepositoryProvider<SearchHistoryRepository>.value(
                    value: searchHistoryRepo,
                  ),
                  RepositoryProvider<PoolRepository>.value(value: poolRepo),
                  RepositoryProvider<UserRepository>.value(value: userRepo),
                  RepositoryProvider<BlacklistedTagsRepository>.value(
                    value: blacklistedTagRepo,
                  ),
                  RepositoryProvider<ArtistRepository>.value(
                    value: artistRepo,
                  ),
                  RepositoryProvider<AutocompleteRepository>.value(
                    value: autocompleteRepo,
                  ),
                  RepositoryProvider<RelatedTagRepository>.value(
                    value: relatedTagRepo,
                  ),
                  RepositoryProvider<WikiRepository>.value(value: wikiRepo),
                  RepositoryProvider<ArtistCommentaryRepository>.value(
                    value: artistCommentaryRepo,
                  ),
                  RepositoryProvider<PostVoteRepository>.value(
                    value: postVoteRepo,
                  ),
                  RepositoryProvider<PoolDescriptionRepository>.value(
                    value: poolDescriptionRepo,
                  ),
                  RepositoryProvider<ExploreRepository>.value(
                    value: exploreRepo,
                  ),
                  RepositoryProvider<PostCountRepository>.value(
                    value: postCountRepo,
                  ),
                  RepositoryProvider<SavedSearchRepository>.value(
                    value: savedSearchRepo,
                  ),
                  RepositoryProvider<FavoriteGroupRepository>.value(
                    value: favoriteGroupRepo,
                  ),
                ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: trendingTagCubit),
                    BlocProvider.value(value: favoritedCubit),
                    BlocProvider.value(value: profileCubit),
                    BlocProvider.value(value: commentBloc),
                    BlocProvider.value(value: artistCommentaryBloc),
                    BlocProvider.value(value: accountCubit),
                    BlocProvider.value(value: authenticationCubit),
                    BlocProvider.value(value: blacklistedTagsBloc),
                    BlocProvider.value(value: poolOverviewBloc),
                    BlocProvider.value(value: tagBloc),
                    BlocProvider.value(value: artistBloc),
                    BlocProvider.value(value: wikiBloc),
                    BlocProvider.value(value: savedSearchBloc),
                    BlocProvider.value(value: favoriteTagBloc),
                    BlocProvider.value(value: exploreBloc),
                    BlocProvider.value(value: currentUserBloc),
                  ],
                  child: const DanbooruHomePage(),
                ),
              );
            case BooruType.gelbooru:
              return GelbooruApp(booru: booru);
          }
        },
      ),
    );
  }
}
