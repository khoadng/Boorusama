// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/application/explores/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/count/post_count_repository_api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/favorites/favorite_group_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
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
    required this.currentUserBooruRepo,
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
    required this.currentUserBooruRepository,
  });

  factory DanbooruProvider.create(
    BuildContext context, {
    required Booru booru,
    required ImageSourceComposer<PostDto> sourceComposer,
    required Widget Function(BuildContext context) builder,
  }) {
    final dio = context.read<DioProvider>().getDio(booru.url);
    final tagInfo = context.read<TagInfo>();
    final api = DanbooruApi(dio);

    final settingRepository = context.read<SettingsRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final currentUserBooruRepo = context.read<CurrentUserBooruRepository>();

    final popularSearchRepo = PopularSearchRepositoryApi(
      currentUserBooruRepository: currentUserBooruRepo,
      api: api,
    );

    final tagRepo = TagRepositoryApi(api, currentUserBooruRepo);

    final artistRepo = ArtistRepositoryApi(api: api);

    final profileRepo = ProfileRepositoryApi(
      currentUserBooruRepository: currentUserBooruRepo,
      api: api,
    );

    final postRepo =
        PostRepositoryApi(api, currentUserBooruRepo, sourceComposer);

    final exploreRepo = ExploreRepositoryApi(
      api: api,
      currentUserBooruRepository: currentUserBooruRepo,
      postRepository: postRepo,
      urlComposer: sourceComposer,
    );

    final commentRepo = CommentRepositoryApi(api, currentUserBooruRepo);

    final userRepo = UserRepositoryApi(
      api,
      currentUserBooruRepo,
      tagInfo.defaultBlacklistedTags,
    );

    final noteRepo = NoteCacher(
      cache: LruCacher(capacity: 100),
      repo: NoteRepositoryApi(api),
    );

    final favoriteRepo = FavoritePostRepositoryApi(api, currentUserBooruRepo);

    final artistCommentaryRepo = ArtistCommentaryCacher(
      cache: LruCacher(capacity: 200),
      repo: ArtistCommentaryRepositoryApi(api, currentUserBooruRepo),
    );

    final poolRepo = PoolRepositoryApi(api, currentUserBooruRepo);

    final blacklistedTagRepo = BlacklistedTagsRepositoryImpl(
      userRepo,
      currentUserBooruRepo,
      api,
    );

    final autocompleteRepo = AutocompleteRepositoryApi(
      api: api,
      currentUserBooruRepository: currentUserBooruRepo,
    );

    final relatedTagRepo = RelatedTagRepositoryApi(api);

    final commentVoteRepo = CommentVoteApiRepository(api, currentUserBooruRepo);

    final wikiRepo = WikiRepositoryApi(api);

    final poolDescriptionRepo = PoolDescriptionRepositoryApi(
      dio: dio,
      endpoint: booru.url,
    );

    final postVoteRepo = PostVoteApiRepositoryApi(
      api: api,
      currentUserBooruRepository: currentUserBooruRepo,
    );

    final postCountRepo = PostCountRepositoryApi(
      api: api,
      currentUserBooruRepository: currentUserBooruRepo,
    );

    final savedSearchRepo = SavedSearchRepositoryApi(api, currentUserBooruRepo);

    final favoriteGroupRepo = FavoriteGroupRepositoryApi(
      api: api,
      currentUserBooruRepository: currentUserBooruRepo,
    );

    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    final trendingTagCubit = TrendingTagCubit(
      popularSearchRepo,
      booru.booruType == BooruType.safebooru ? tagInfo.r18Tags.toSet() : {},
    )..getTags();

    return DanbooruProvider(
      builder: builder,
      currentUserBooruRepo: currentUserBooruRepo,
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
      currentUserBooruRepository: currentUserBooruRepo,
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
    final currentUserBooruRepo = context.read<CurrentUserBooruRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    final tagInfo = context.read<TagInfo>();

    final trendingTagCubit = context.read<TrendingTagCubit>();

    return DanbooruProvider(
      builder: builder,
      currentUserBooruRepo: currentUserBooruRepo,
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
      currentUserBooruRepository: currentUserBooruRepo,
      booru: booru,
      tagInfo: tagInfo,
      trendingTagCubit: trendingTagCubit,
    );
  }

  final Widget Function(BuildContext context) builder;

  final TagRepository tagRepo;
  final ProfileRepository profileRepo;
  final FavoritePostRepository favoriteRepo;
  final CurrentUserBooruRepository currentUserBooruRepo;
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
  final CurrentUserBooruRepository currentUserBooruRepository;

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
      currentUserBooruRepository: currentUserBooruRepository,
    );
    final artistCommentaryBloc = ArtistCommentaryBloc(
      artistCommentaryRepository: artistCommentaryRepo,
    );
    final authenticationCubit = AuthenticationCubit(
      currentUserBooruRepository: currentUserBooruRepository,
      booru: booru,
    )..logIn();
    final blacklistedTagsBloc = BlacklistedTagsBloc(
      currentUserBooruRepository: currentUserBooruRepository,
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
          postVoteRepository: postVoteRepo,
          poolRepository: poolRepo,
          currentUserBooruRepository: currentUserBooruRepository,
        );

    final exploreBloc = ExploreBloc(
      exploreRepository: exploreRepo,
      popular: create(),
      hot: create(),
      mostViewed: create(),
    )..add(const ExploreFetched());

    final currentUserBloc = CurrentUserBloc(
      userRepository: userRepo,
      currentUserBooruRepository: currentUserBooruRepo,
    )..add(const CurrentUserFetched());

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tagRepo),
        RepositoryProvider.value(value: profileRepo),
        RepositoryProvider.value(value: favoriteRepo),
        RepositoryProvider.value(value: currentUserBooruRepo),
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
