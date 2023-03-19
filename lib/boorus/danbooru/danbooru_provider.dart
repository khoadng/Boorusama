// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
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
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/user/current_user_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/wiki/wiki.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profiles.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/count/post_count_repository_api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/favorites/favorite_group_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';
import 'package:boorusama/core/domain/searches/searches.dart';
import 'package:boorusama/core/domain/settings/settings_repository.dart';
import 'package:boorusama/core/domain/tags/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/main.dart';
import 'infra/dtos/post_dto.dart';

class DanbooruProvider extends StatelessWidget {
  const DanbooruProvider({
    super.key,
    required this.builder,
    required this.tagRepo,
    required this.profileRepo,
    required this.favoriteRepo,
    required this.accountRepo,
    required this.settingRepository,
    required this.noteRepo,
    required this.postRepo,
    required this.searchHistoryRepo,
    required this.poolRepo,
    required this.userRepo,
    required this.blacklistedTagRepo,
    required this.artistRepo,
    required this.autocompleteRepo,
    required this.relatedTagRepo,
    required this.wikiRepo,
    required this.artistCommentaryRepo,
    required this.postVoteRepo,
    required this.poolDescriptionRepo,
    required this.exploreRepo,
    required this.postCountRepo,
    required this.savedSearchRepo,
    required this.favoriteGroupRepo,
    required this.commentVoteRepo,
    required this.commentRepo,
    required this.popularSearchRepo,
    required this.favoriteTagsRepo,
    required this.booru,
    required this.tagInfo,
    required this.trendingTagCubit,
  });

  factory DanbooruProvider.create(
    BuildContext context, {
    required Booru booru,
    required ImageSourceComposer<PostDto> sourceComposer,
    required Widget Function(BuildContext context) builder,
  }) {
    final dio = context.read<DioProvider>().getDio(booru.url);
    final accountRepo = context.read<AccountRepository>();
    final tagInfo = context.read<TagInfo>();
    final api = DanbooruApi(dio);

    final settingRepository = context.read<SettingsRepository>();
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

    final postRepo = PostRepositoryApi(api, accountRepo, sourceComposer);

    final exploreRepo = ExploreRepositoryApi(
      api: api,
      accountRepository: accountRepo,
      postRepository: postRepo,
      urlComposer: sourceComposer,
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

    final commentVoteRepo = CommentVoteApiRepository(api, accountRepo);

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

    final savedSearchRepo = SavedSearchRepositoryApi(api, accountRepo);

    final favoriteGroupRepo = FavoriteGroupRepositoryApi(
      api: api,
      accountRepository: accountRepo,
    );

    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    final trendingTagCubit = TrendingTagCubit(
      popularSearchRepo,
      booru.booruType == BooruType.safebooru ? tagInfo.r18Tags.toSet() : {},
    )..getTags();

    return DanbooruProvider(
      builder: builder,
      accountRepo: accountRepo,
      artistCommentaryRepo: artistCommentaryRepo,
      artistRepo: artistRepo,
      autocompleteRepo: autocompleteRepo,
      blacklistedTagRepo: blacklistedTagRepo,
      exploreRepo: exploreRepo,
      favoriteGroupRepo: favoriteGroupRepo,
      favoriteRepo: favoriteRepo,
      noteRepo: noteRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
      postCountRepo: postCountRepo,
      postRepo: postRepo,
      postVoteRepo: postVoteRepo,
      profileRepo: profileRepo,
      relatedTagRepo: relatedTagRepo,
      savedSearchRepo: savedSearchRepo,
      searchHistoryRepo: searchHistoryRepo,
      settingRepository: settingRepository,
      tagRepo: tagRepo,
      userRepo: userRepo,
      wikiRepo: wikiRepo,
      commentRepo: commentRepo,
      commentVoteRepo: commentVoteRepo,
      popularSearchRepo: popularSearchRepo,
      favoriteTagsRepo: favoriteTagRepo,
      booru: booru,
      tagInfo: tagInfo,
      trendingTagCubit: trendingTagCubit,
    );
  }

  factory DanbooruProvider.of(
    BuildContext context, {
    required Booru booru,
    required Widget Function(BuildContext context) builder,
  }) {
    final settingRepository = context.read<SettingsRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final artistRepo = context.read<ArtistRepository>();
    final popularSearchRepo = context.read<PopularSearchRepository>();
    final tagRepo = context.read<TagRepository>();
    final profileRepo = context.read<ProfileRepository>();
    final postRepo = context.read<DanbooruPostRepository>();
    final exploreRepo = context.read<ExploreRepository>();
    final commentRepo = context.read<CommentRepository>();
    final userRepo = context.read<UserRepository>();
    final noteRepo = context.read<NoteRepository>();
    final favoriteRepo = context.read<FavoritePostRepository>();
    final artistCommentaryRepo = context.read<ArtistCommentaryRepository>();
    final poolRepo = context.read<PoolRepository>();
    final blacklistedTagRepo = context.read<BlacklistedTagsRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final relatedTagRepo = context.read<RelatedTagRepository>();
    final commentVoteRepo = context.read<CommentVoteRepository>();
    final wikiRepo = context.read<WikiRepository>();
    final poolDescriptionRepo = context.read<PoolDescriptionRepository>();
    final postVoteRepo = context.read<PostVoteRepository>();
    final postCountRepo = context.read<PostCountRepository>();
    final savedSearchRepo = context.read<SavedSearchRepository>();
    final favoriteGroupRepo = context.read<FavoriteGroupRepository>();
    final accountRepo = context.read<AccountRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final tagInfo = context.read<TagInfo>();

    final trendingTagCubit = context.read<TrendingTagCubit>();

    return DanbooruProvider(
      builder: builder,
      accountRepo: accountRepo,
      artistCommentaryRepo: artistCommentaryRepo,
      artistRepo: artistRepo,
      autocompleteRepo: autocompleteRepo,
      blacklistedTagRepo: blacklistedTagRepo,
      exploreRepo: exploreRepo,
      favoriteGroupRepo: favoriteGroupRepo,
      favoriteRepo: favoriteRepo,
      noteRepo: noteRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
      postCountRepo: postCountRepo,
      postRepo: postRepo,
      postVoteRepo: postVoteRepo,
      profileRepo: profileRepo,
      relatedTagRepo: relatedTagRepo,
      savedSearchRepo: savedSearchRepo,
      searchHistoryRepo: searchHistoryRepo,
      settingRepository: settingRepository,
      tagRepo: tagRepo,
      userRepo: userRepo,
      wikiRepo: wikiRepo,
      commentRepo: commentRepo,
      commentVoteRepo: commentVoteRepo,
      popularSearchRepo: popularSearchRepo,
      favoriteTagsRepo: favoriteTagRepo,
      booru: booru,
      tagInfo: tagInfo,
      trendingTagCubit: trendingTagCubit,
    );
  }

  final Widget Function(BuildContext context) builder;

  final TagRepository tagRepo;
  final ProfileRepository profileRepo;
  final FavoritePostRepository favoriteRepo;
  final AccountRepository accountRepo;
  final SettingsRepository settingRepository;
  final NoteRepository noteRepo;
  final DanbooruPostRepository postRepo;
  final SearchHistoryRepository searchHistoryRepo;
  final PoolRepository poolRepo;
  final UserRepository userRepo;
  final BlacklistedTagsRepository blacklistedTagRepo;
  final ArtistRepository artistRepo;
  final AutocompleteRepository autocompleteRepo;
  final RelatedTagRepository relatedTagRepo;
  final WikiRepository wikiRepo;
  final ArtistCommentaryRepository artistCommentaryRepo;
  final PostVoteRepository postVoteRepo;
  final PoolDescriptionRepository poolDescriptionRepo;
  final ExploreRepository exploreRepo;
  final PostCountRepository postCountRepo;
  final SavedSearchRepository savedSearchRepo;
  final FavoriteGroupRepository favoriteGroupRepo;
  final CommentVoteRepository commentVoteRepo;
  final CommentRepository commentRepo;
  final PopularSearchRepository popularSearchRepo;
  final FavoriteTagRepository favoriteTagsRepo;

  final TrendingTagCubit trendingTagCubit;

  final Booru booru;
  final TagInfo tagInfo;

  @override
  Widget build(BuildContext context) {
    final favoritedCubit = FavoritesCubit(postRepository: postRepo);
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
        RepositoryProvider.value(value: tagRepo),
        RepositoryProvider.value(value: profileRepo),
        RepositoryProvider.value(value: favoriteRepo),
        RepositoryProvider.value(value: accountRepo),
        RepositoryProvider.value(value: settingRepository),
        RepositoryProvider.value(value: noteRepo),
        RepositoryProvider.value(value: postRepo),
        RepositoryProvider.value(value: commentRepo),
        RepositoryProvider.value(value: commentVoteRepo),
        RepositoryProvider.value(value: popularSearchRepo),
        RepositoryProvider.value(value: searchHistoryRepo),
        RepositoryProvider.value(value: poolRepo),
        RepositoryProvider.value(value: userRepo),
        RepositoryProvider.value(value: blacklistedTagRepo),
        RepositoryProvider.value(value: artistRepo),
        RepositoryProvider.value(value: autocompleteRepo),
        RepositoryProvider.value(value: relatedTagRepo),
        RepositoryProvider.value(value: wikiRepo),
        RepositoryProvider.value(value: artistCommentaryRepo),
        RepositoryProvider.value(value: postVoteRepo),
        RepositoryProvider.value(value: poolDescriptionRepo),
        RepositoryProvider.value(value: exploreRepo),
        RepositoryProvider.value(value: postCountRepo),
        RepositoryProvider.value(value: savedSearchRepo),
        RepositoryProvider.value(value: favoriteGroupRepo),
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
          BlocProvider.value(value: exploreBloc),
          BlocProvider.value(value: currentUserBloc),
        ],
        child: Builder(builder: builder),
      ),
    );
  }
}
