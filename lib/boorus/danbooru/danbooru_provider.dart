// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comments.dart';
import 'package:boorusama/boorus/danbooru/application/comments/comment_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/users.dart';
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
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
import 'package:boorusama/boorus/danbooru/infra/repositories/pool/pool_cacher.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_artist_character_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/explore_repository_cacher.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/related_tag_repository_empty.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'package:boorusama/core/provider.dart';
import 'infra/dtos/post_dto.dart';

class DanbooruProvider extends StatelessWidget {
  const DanbooruProvider({
    super.key,
    required this.builder,
    required this.tagRepo,
    required this.profileRepo,
    required this.favoriteRepo,
    required this.currentBooruConfigRepo,
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
    required this.tagInfo,
    required this.currentBooruConfigRepository,
    required this.fileNameGenerator,
    required this.blacklistedTagsBloc,
    required this.currentUserBloc,
    required this.poolOverviewBloc,
    required this.artistBloc,
    required this.tagBloc,
    required this.wikiBloc,
    required this.savedSearchBloc,
    required this.commentBloc,
    required this.artistCommentaryBloc,
    required this.favoritesCubit,
    required this.profileCubit,
    required this.favoritePostCubit,
    required this.postVoteCubit,
    required this.danbooruArtistCharacterPostRepository,
    required this.commentsCubit,
  });

  factory DanbooruProvider.create(
    BuildContext context, {
    required WidgetRef ref,
    required ImageSourceComposer<PostDto> sourceComposer,
    required Widget Function(BuildContext context) builder,
  }) {
    final booruConfig = ref.read(currentBooruConfigProvider);
    final dio = ref.read(dioProvider(booruConfig.url));
    final tagInfo = context.read<TagInfo>();
    final api = DanbooruApi(dio);

    final settingRepository = context.read<SettingsRepository>();
    final searchHistoryRepo = context.read<SearchHistoryRepository>();
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();
    final booruUserIdentityProvider = context.read<BooruUserIdentityProvider>();

    final fileNameGenerator = BoorusamaStyledFileNameGenerator();

    final popularSearchRepo = PopularSearchRepositoryApi(
      currentBooruConfigRepository: currentBooruConfigRepo,
      api: api,
    );

    final tagRepo = TagRepositoryApi(api, currentBooruConfigRepo);

    final artistRepo = ArtistRepositoryApi(api: api);

    final profileRepo = ProfileRepositoryApi(
      currentBooruConfigRepository: currentBooruConfigRepo,
      api: api,
    );

    final postRepo = PostRepositoryApi(
      api,
      currentBooruConfigRepo,
      sourceComposer,
      settingRepository,
    );

    final exploreRepo = ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        api: api,
        currentBooruConfigRepository: currentBooruConfigRepo,
        postRepository: postRepo,
        urlComposer: sourceComposer,
        settingsRepository: settingRepository,
      ),
      popularStaleDuration: const Duration(minutes: 20),
      mostViewedStaleDuration: const Duration(hours: 1),
      hotStaleDuration: const Duration(minutes: 5),
    );

    final commentRepo = CommentCacher(
      cache: LruCacher(capacity: 100),
      repo: CommentRepositoryApi(api, currentBooruConfigRepo),
    );

    final userRepo = UserRepositoryApi(
      api,
      currentBooruConfigRepo,
      tagInfo.defaultBlacklistedTags,
    );

    final noteRepo = NoteCacher(
      cache: LruCacher(capacity: 100),
      repo: NoteRepositoryApi(api),
    );

    final favoriteRepo = FavoritePostRepositoryApi(api, currentBooruConfigRepo);

    final artistCommentaryRepo = ArtistCommentaryCacher(
      cache: LruCacher(capacity: 200),
      repo: ArtistCommentaryRepositoryApi(api, currentBooruConfigRepo),
    );

    final poolRepo = PoolCacher(PoolRepositoryApi(api, currentBooruConfigRepo));

    final blacklistedTagRepo = BlacklistedTagsRepositoryImpl(
      userRepo,
      currentBooruConfigRepo,
      api,
    );

    final autocompleteRepo = AutocompleteRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
    );

    final relatedTagRepo = RelatedTagRepositoryEmpty();

    final commentVoteRepo =
        CommentVoteApiRepository(api, currentBooruConfigRepo);

    final wikiRepo = WikiRepositoryApi(api);

    final poolDescriptionRepo = PoolDescriptionRepositoryApi(
      dio: dio,
      endpoint: booruConfig.url,
    );

    final postVoteRepo = PostVoteApiRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
      booruUserIdentityProvider: booruUserIdentityProvider,
    );

    final postCountRepo = PostCountRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
    );

    final savedSearchRepo =
        SavedSearchRepositoryApi(api, currentBooruConfigRepo);

    final favoriteGroupRepo = FavoriteGroupRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
    );

    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    final blacklistedTagsBloc = BlacklistedTagsBloc(
      currentBooruConfigRepository: currentBooruConfigRepo,
      blacklistedTagsRepository: blacklistedTagRepo,
      booruUserIdentityProvider: booruUserIdentityProvider,
    )..add(const BlacklistedTagRequested());

    final currentUserBloc = CurrentUserBloc(
      userRepository: userRepo,
      currentBooruConfigRepository: currentBooruConfigRepo,
      booruUserIdentityProvider: booruUserIdentityProvider,
    )..add(const CurrentUserFetched());

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

    final commentBloc = CommentBloc(
      commentVoteRepository: commentVoteRepo,
      commentRepository: commentRepo,
      currentBooruConfigRepository: currentBooruConfigRepo,
      booruUserIdentityProvider: booruUserIdentityProvider,
    );
    final artistCommentaryBloc = ArtistCommentaryCubit(
      repository: artistCommentaryRepo,
    );

    final favoritedCubit = FavoritesCubit(postRepository: postRepo);
    final profileCubit = ProfileCubit(profileRepository: profileRepo);
    final favoritePostCubit = FavoritePostCubit(
      favoritePostRepository: favoriteRepo,
      userIdentityProvider: booruUserIdentityProvider,
      currentBooruConfigRepository: currentBooruConfigRepo,
      limit: 200,
    );
    final postVoteCubit = PostVoteCubit(postVoteRepo);
    final artistCharacterPostRepository = DanbooruArtistCharacterPostRepository(
      repository: postRepo,
      cache: LruCacher(),
    );
    final commentsCubit = CommentsCubit(
      repository: commentRepo,
    );

    return DanbooruProvider(
      builder: builder,
      currentBooruConfigRepo: currentBooruConfigRepo,
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
      currentBooruConfigRepository: currentBooruConfigRepo,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      blacklistedTagsBloc: blacklistedTagsBloc,
      currentUserBloc: currentUserBloc,
      poolOverviewBloc: poolOverviewBloc,
      artistBloc: artistBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      commentBloc: commentBloc,
      artistCommentaryBloc: artistCommentaryBloc,
      favoritesCubit: favoritedCubit,
      profileCubit: profileCubit,
      favoritePostCubit: favoritePostCubit,
      postVoteCubit: postVoteCubit,
      danbooruArtistCharacterPostRepository: artistCharacterPostRepository,
      commentsCubit: commentsCubit,
    );
  }

  factory DanbooruProvider.of(
    BuildContext context, {
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
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();

    final tagInfo = context.read<TagInfo>();

    final blacklistedTagsBloc = context.read<BlacklistedTagsBloc>();
    // final exploreBloc = context.read<ExploreBloc>();
    final currentUserBloc = context.read<CurrentUserBloc>();
    final poolOverviewBloc = context.read<PoolOverviewBloc>();
    final artistBloc = context.read<ArtistBloc>();
    final tagBloc = context.read<TagBloc>();
    final wikiBloc = context.read<WikiBloc>();
    final savedSearchBloc = context.read<SavedSearchBloc>();
    final commentBloc = context.read<CommentBloc>();
    final artistCommentaryBloc = context.read<ArtistCommentaryCubit>();
    final favoritesCubit = context.read<FavoritesCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final favoritePostCubit = context.read<FavoritePostCubit>();
    final postVoteCubit = context.read<PostVoteCubit>();
    final artistCharacterPostRepository =
        context.read<DanbooruArtistCharacterPostRepository>();
    final commentsCubit = context.read<CommentsCubit>();

    return DanbooruProvider(
      builder: builder,
      currentBooruConfigRepo: currentBooruConfigRepo,
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
      currentBooruConfigRepository: currentBooruConfigRepo,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      blacklistedTagsBloc: blacklistedTagsBloc,
      currentUserBloc: currentUserBloc,
      poolOverviewBloc: poolOverviewBloc,
      artistBloc: artistBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      commentBloc: commentBloc,
      artistCommentaryBloc: artistCommentaryBloc,
      profileCubit: profileCubit,
      favoritesCubit: favoritesCubit,
      favoritePostCubit: favoritePostCubit,
      postVoteCubit: postVoteCubit,
      danbooruArtistCharacterPostRepository: artistCharacterPostRepository,
      commentsCubit: commentsCubit,
    );
  }

  final Widget Function(BuildContext context) builder;

  final TagRepository tagRepo;
  final ProfileRepository profileRepo;
  final FavoritePostRepository favoriteRepo;
  final CurrentBooruConfigRepository currentBooruConfigRepo;
  final SettingsRepository settingRepository;
  final NoteRepository noteRepo;
  final DanbooruPostRepository postRepo;
  final DanbooruArtistCharacterPostRepository
      danbooruArtistCharacterPostRepository;
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
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final FileNameGenerator fileNameGenerator;

  final BlacklistedTagsBloc blacklistedTagsBloc;
  final CurrentUserBloc currentUserBloc;
  final PoolOverviewBloc poolOverviewBloc;
  final ArtistBloc artistBloc;
  final TagBloc tagBloc;
  final WikiBloc wikiBloc;
  final SavedSearchBloc savedSearchBloc;
  final CommentBloc commentBloc;
  final ArtistCommentaryCubit artistCommentaryBloc;
  final FavoritesCubit favoritesCubit;
  final ProfileCubit profileCubit;
  final FavoritePostCubit favoritePostCubit;
  final PostVoteCubit postVoteCubit;
  final CommentsCubit commentsCubit;

  final TagInfo tagInfo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tagRepo),
        RepositoryProvider.value(value: profileRepo),
        RepositoryProvider.value(value: favoriteRepo),
        RepositoryProvider.value(value: currentBooruConfigRepo),
        RepositoryProvider.value(value: settingRepository),
        RepositoryProvider.value(value: noteRepo),
        RepositoryProvider.value(value: postRepo),
        RepositoryProvider.value(value: danbooruArtistCharacterPostRepository),
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
        RepositoryProvider.value(value: fileNameGenerator),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: favoritesCubit),
          BlocProvider.value(value: favoritePostCubit),
          BlocProvider.value(value: profileCubit),
          BlocProvider.value(value: commentBloc),
          BlocProvider.value(value: artistCommentaryBloc),
          BlocProvider.value(value: blacklistedTagsBloc),
          BlocProvider.value(value: poolOverviewBloc),
          BlocProvider.value(value: tagBloc),
          BlocProvider.value(value: artistBloc),
          BlocProvider.value(value: wikiBloc),
          BlocProvider.value(value: savedSearchBloc),
          BlocProvider.value(value: currentUserBloc),
          BlocProvider.value(value: postVoteCubit),
          BlocProvider.value(value: commentsCubit),
        ],
        child: ProviderScope(
          overrides: [
            postCountRepoProvider.overrideWithValue(postCountRepo),
            autocompleteRepoProvider.overrideWithValue(autocompleteRepo),
            noteRepoProvider.overrideWithValue(noteRepo),
            poolRepoProvider.overrideWithValue(poolRepo),
            postVoteRepoProvider.overrideWithValue(postVoteRepo),
            danbooruPostRepoProvider.overrideWithValue(postRepo),
            poolDescriptionRepoProvider.overrideWithValue(poolDescriptionRepo),
            popularSearchProvider.overrideWithValue(popularSearchRepo),
          ],
          child: Builder(builder: builder),
        ),
      ),
    );
  }
}

final noteRepoProvider =
    Provider<NoteRepository>((ref) => throw UnimplementedError());

final poolRepoProvider =
    Provider<PoolRepository>((ref) => throw UnimplementedError());

final postVoteRepoProvider =
    Provider<PostVoteRepository>((ref) => throw UnimplementedError());

final danbooruPostRepoProvider =
    Provider<DanbooruPostRepository>((ref) => throw UnimplementedError());

final postCountRepoProvider =
    Provider<PostCountRepository>((ref) => throw UnimplementedError());

final postCountStateProvider =
    StateNotifierProvider<PostCountNotifier, PostCountState>((ref) {
  final postCountRepo = ref.watch(postCountRepoProvider);
  final currentBooruConfigRepo = ref.watch(currentBooruConfigRepoProvider);
  final booruFactory = ref.watch(booruFactoryProvider);

  return PostCountNotifier(
    repository: postCountRepo,
    currentBooruConfigRepository: currentBooruConfigRepo,
    booruFactory: booruFactory,
  );
}, dependencies: [
  postCountRepoProvider,
  currentBooruConfigRepoProvider,
  booruFactoryProvider,
]);

final postCountProvider = Provider<PostCountState>((ref) {
  return ref.watch(postCountStateProvider);
}, dependencies: [
  postCountStateProvider,
]);

final poolDescriptionRepoProvider =
    Provider<PoolDescriptionRepository>((ref) => throw UnimplementedError());

final popularSearchProvider = Provider<PopularSearchRepository>((ref) {
  throw UnimplementedError();
});
