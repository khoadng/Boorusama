// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/comments/comment_cacher.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis.dart';
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
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'package:boorusama/core/provider.dart';

class DanbooruProvider extends StatelessWidget {
  const DanbooruProvider({
    super.key,
    required this.builder,
    required this.tagRepo,
    required this.profileRepo,
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
    required this.postVoteRepo,
    required this.poolDescriptionRepo,
    required this.exploreRepo,
    required this.savedSearchRepo,
    required this.commentVoteRepo,
    required this.commentRepo,
    required this.popularSearchRepo,
    required this.favoriteTagsRepo,
    required this.tagInfo,
    required this.currentBooruConfigRepository,
    required this.fileNameGenerator,
    required this.blacklistedTagsBloc,
    required this.poolOverviewBloc,
    required this.tagBloc,
    required this.wikiBloc,
    required this.savedSearchBloc,
    required this.profileCubit,
    required this.postVoteCubit,
    required this.danbooruArtistCharacterPostRepository,
    required this.commentsCubit,
  });

  factory DanbooruProvider.create(
    BuildContext context, {
    required WidgetRef ref,
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
      settingRepository,
    );

    final exploreRepo = ExploreRepositoryCacher(
      repository: ExploreRepositoryApi(
        api: api,
        currentBooruConfigRepository: currentBooruConfigRepo,
        postRepository: postRepo,
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

    final savedSearchRepo =
        SavedSearchRepositoryApi(api, currentBooruConfigRepo);

    final favoriteTagRepo = context.read<FavoriteTagRepository>();

    final blacklistedTagsBloc = BlacklistedTagsBloc(
      currentBooruConfigRepository: currentBooruConfigRepo,
      blacklistedTagsRepository: blacklistedTagRepo,
      booruUserIdentityProvider: booruUserIdentityProvider,
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

    final wikiBloc = WikiBloc(
      wikiRepository: WikiCacher(
        cache: LruCacher(capacity: 200),
        repo: wikiRepo,
      ),
    );

    final savedSearchBloc = SavedSearchBloc(
      savedSearchRepository: savedSearchRepo,
    );

    final profileCubit = ProfileCubit(profileRepository: profileRepo);

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
      artistRepo: artistRepo,
      autocompleteRepo: autocompleteRepo,
      blacklistedTagRepo: blacklistedTagRepo,
      exploreRepo: exploreRepo,
      noteRepo: noteRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
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
      poolOverviewBloc: poolOverviewBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      profileCubit: profileCubit,
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
    final poolRepo = context.read<PoolRepository>();
    final blacklistedTagRepo = context.read<BlacklistedTagsRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final relatedTagRepo = context.read<RelatedTagRepository>();
    final commentVoteRepo = context.read<CommentVoteRepository>();
    final wikiRepo = context.read<WikiRepository>();
    final poolDescriptionRepo = context.read<PoolDescriptionRepository>();
    final postVoteRepo = context.read<PostVoteRepository>();
    final savedSearchRepo = context.read<SavedSearchRepository>();
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();

    final tagInfo = context.read<TagInfo>();

    final blacklistedTagsBloc = context.read<BlacklistedTagsBloc>();
    final poolOverviewBloc = context.read<PoolOverviewBloc>();
    final tagBloc = context.read<TagBloc>();
    final wikiBloc = context.read<WikiBloc>();
    final savedSearchBloc = context.read<SavedSearchBloc>();
    final profileCubit = context.read<ProfileCubit>();
    final postVoteCubit = context.read<PostVoteCubit>();
    final artistCharacterPostRepository =
        context.read<DanbooruArtistCharacterPostRepository>();
    final commentsCubit = context.read<CommentsCubit>();

    return DanbooruProvider(
      builder: builder,
      currentBooruConfigRepo: currentBooruConfigRepo,
      artistRepo: artistRepo,
      autocompleteRepo: autocompleteRepo,
      blacklistedTagRepo: blacklistedTagRepo,
      exploreRepo: exploreRepo,
      noteRepo: noteRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
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
      poolOverviewBloc: poolOverviewBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      profileCubit: profileCubit,
      postVoteCubit: postVoteCubit,
      danbooruArtistCharacterPostRepository: artistCharacterPostRepository,
      commentsCubit: commentsCubit,
    );
  }

  final Widget Function(BuildContext context) builder;

  final TagRepository tagRepo;
  final ProfileRepository profileRepo;
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
  final PostVoteRepository postVoteRepo;
  final PoolDescriptionRepository poolDescriptionRepo;
  final ExploreRepository exploreRepo;
  final SavedSearchRepository savedSearchRepo;
  final CommentVoteRepository commentVoteRepo;
  final CommentRepository commentRepo;
  final PopularSearchRepository popularSearchRepo;
  final FavoriteTagRepository favoriteTagsRepo;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final FileNameGenerator fileNameGenerator;

  final BlacklistedTagsBloc blacklistedTagsBloc;
  final PoolOverviewBloc poolOverviewBloc;
  final TagBloc tagBloc;
  final WikiBloc wikiBloc;
  final SavedSearchBloc savedSearchBloc;
  final ProfileCubit profileCubit;
  final PostVoteCubit postVoteCubit;
  final CommentsCubit commentsCubit;

  final TagInfo tagInfo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tagRepo),
        RepositoryProvider.value(value: profileRepo),
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
        RepositoryProvider.value(value: postVoteRepo),
        RepositoryProvider.value(value: poolDescriptionRepo),
        RepositoryProvider.value(value: exploreRepo),
        RepositoryProvider.value(value: savedSearchRepo),
        RepositoryProvider.value(value: fileNameGenerator),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profileCubit),
          BlocProvider.value(value: blacklistedTagsBloc),
          BlocProvider.value(value: poolOverviewBloc),
          BlocProvider.value(value: tagBloc),
          BlocProvider.value(value: wikiBloc),
          BlocProvider.value(value: savedSearchBloc),
          BlocProvider.value(value: postVoteCubit),
          BlocProvider.value(value: commentsCubit),
        ],
        child: ProviderScope(
          overrides: [
            autocompleteRepoProvider.overrideWithValue(autocompleteRepo),
            poolRepoProvider.overrideWithValue(poolRepo),
            postVoteRepoProvider.overrideWithValue(postVoteRepo),
            danbooruArtistCharacterPostRepoProvider
                .overrideWithValue(danbooruArtistCharacterPostRepository),
            poolDescriptionRepoProvider.overrideWithValue(poolDescriptionRepo),
            popularSearchProvider.overrideWithValue(popularSearchRepo),
          ],
          child: Builder(builder: builder),
        ),
      ),
    );
  }
}

final danbooruApiProvider = Provider<DanbooruApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return DanbooruApi(dio);
});

final poolRepoProvider =
    Provider<PoolRepository>((ref) => throw UnimplementedError());

final postVoteRepoProvider =
    Provider<PostVoteRepository>((ref) => throw UnimplementedError());

final danbooruPostRepoProvider = Provider<DanbooruPostRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfigRepo = ref.watch(currentBooruConfigRepoProvider);
  final settingsRepo = ref.watch(settingsRepoProvider);

  return PostRepositoryApi(api, booruConfigRepo, settingsRepo);
});

final danbooruArtistCharacterPostRepoProvider =
    Provider<DanbooruPostRepository>((ref) => throw UnimplementedError());

final poolDescriptionRepoProvider =
    Provider<PoolDescriptionRepository>((ref) => throw UnimplementedError());

final popularSearchProvider = Provider<PopularSearchRepository>((ref) {
  throw UnimplementedError();
});
