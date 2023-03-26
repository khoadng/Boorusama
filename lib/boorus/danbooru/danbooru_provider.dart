// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/artists.dart';
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
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/core/application/authentication.dart';
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
import 'package:boorusama/main.dart';
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
    required this.booru,
    required this.tagInfo,
    required this.trendingTagCubit,
    required this.currentBooruConfigRepository,
    required this.fileNameGenerator,
    required this.blacklistedTagsBloc,
    required this.exploreBloc,
    required this.currentUserBloc,
    required this.authenticationCubit,
    required this.poolOverviewBloc,
    required this.artistBloc,
    required this.tagBloc,
    required this.wikiBloc,
    required this.savedSearchBloc,
    required this.commentBloc,
    required this.artistCommentaryBloc,
    required this.favoritesCubit,
    required this.profileCubit,
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
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();

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

    final postRepo =
        PostRepositoryApi(api, currentBooruConfigRepo, sourceComposer);

    final exploreRepo = ExploreRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
      postRepository: postRepo,
      urlComposer: sourceComposer,
    );

    final commentRepo = CommentRepositoryApi(api, currentBooruConfigRepo);

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

    final poolRepo = PoolRepositoryApi(api, currentBooruConfigRepo);

    final blacklistedTagRepo = BlacklistedTagsRepositoryImpl(
      userRepo,
      currentBooruConfigRepo,
      api,
    );

    final autocompleteRepo = AutocompleteRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
    );

    final relatedTagRepo = RelatedTagRepositoryApi(api);

    final commentVoteRepo =
        CommentVoteApiRepository(api, currentBooruConfigRepo);

    final wikiRepo = WikiRepositoryApi(api);

    final poolDescriptionRepo = PoolDescriptionRepositoryApi(
      dio: dio,
      endpoint: booru.url,
    );

    final postVoteRepo = PostVoteApiRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
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

    final trendingTagCubit = TrendingTagCubit(
      popularSearchRepo,
      booru.booruType == BooruType.safebooru ? tagInfo.r18Tags.toSet() : {},
    )..getTags();

    final blacklistedTagsBloc = BlacklistedTagsBloc(
      currentBooruConfigRepository: currentBooruConfigRepo,
      blacklistedTagsRepository: blacklistedTagRepo,
    )..add(const BlacklistedTagRequested());

    PostBloc create() => PostBloc(
          postRepository: postRepo,
          blacklistedTagsRepository: blacklistedTagRepo,
          favoritePostRepository: favoriteRepo,
          postVoteRepository: postVoteRepo,
          poolRepository: poolRepo,
          currentBooruConfigRepository: currentBooruConfigRepo,
        );

    final exploreBloc = ExploreBloc(
      exploreRepository: exploreRepo,
      popular: create(),
      hot: create(),
      mostViewed: create(),
    )..add(const ExploreFetched());

    final currentUserBloc = CurrentUserBloc(
      userRepository: userRepo,
      currentBooruConfigRepository: currentBooruConfigRepo,
    )..add(const CurrentUserFetched());

    final authenticationCubit = AuthenticationCubit(
      currentBooruConfigRepository: currentBooruConfigRepo,
      booru: booru,
    )..logIn();

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
    );
    final artistCommentaryBloc = ArtistCommentaryBloc(
      artistCommentaryRepository: artistCommentaryRepo,
    );

    final favoritedCubit = FavoritesCubit(postRepository: postRepo);
    final profileCubit = ProfileCubit(profileRepository: profileRepo);

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
      booru: booru,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      trendingTagCubit: trendingTagCubit,
      blacklistedTagsBloc: blacklistedTagsBloc,
      exploreBloc: exploreBloc,
      currentUserBloc: currentUserBloc,
      authenticationCubit: authenticationCubit,
      poolOverviewBloc: poolOverviewBloc,
      artistBloc: artistBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      commentBloc: commentBloc,
      artistCommentaryBloc: artistCommentaryBloc,
      favoritesCubit: favoritedCubit,
      profileCubit: profileCubit,
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
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();

    final tagInfo = context.read<TagInfo>();

    final trendingTagCubit = context.read<TrendingTagCubit>();
    final blacklistedTagsBloc = context.read<BlacklistedTagsBloc>();
    final exploreBloc = context.read<ExploreBloc>();
    final currentUserBloc = context.read<CurrentUserBloc>();
    final authenticationCubit = context.read<AuthenticationCubit>();
    final poolOverviewBloc = context.read<PoolOverviewBloc>();
    final artistBloc = context.read<ArtistBloc>();
    final tagBloc = context.read<TagBloc>();
    final wikiBloc = context.read<WikiBloc>();
    final savedSearchBloc = context.read<SavedSearchBloc>();
    final commentBloc = context.read<CommentBloc>();
    final artistCommentaryBloc = context.read<ArtistCommentaryBloc>();
    final favoritesCubit = context.read<FavoritesCubit>();
    final profileCubit = context.read<ProfileCubit>();

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
      booru: booru,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      trendingTagCubit: trendingTagCubit,
      blacklistedTagsBloc: blacklistedTagsBloc,
      exploreBloc: exploreBloc,
      currentUserBloc: currentUserBloc,
      authenticationCubit: authenticationCubit,
      poolOverviewBloc: poolOverviewBloc,
      artistBloc: artistBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      commentBloc: commentBloc,
      artistCommentaryBloc: artistCommentaryBloc,
      profileCubit: profileCubit,
      favoritesCubit: favoritesCubit,
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

  final TrendingTagCubit trendingTagCubit;
  final BlacklistedTagsBloc blacklistedTagsBloc;
  final ExploreBloc exploreBloc;
  final CurrentUserBloc currentUserBloc;
  final AuthenticationCubit authenticationCubit;
  final PoolOverviewBloc poolOverviewBloc;
  final ArtistBloc artistBloc;
  final TagBloc tagBloc;
  final WikiBloc wikiBloc;
  final SavedSearchBloc savedSearchBloc;
  final CommentBloc commentBloc;
  final ArtistCommentaryBloc artistCommentaryBloc;
  final FavoritesCubit favoritesCubit;
  final ProfileCubit profileCubit;

  final Booru booru;
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
          BlocProvider.value(value: trendingTagCubit),
          BlocProvider.value(value: favoritesCubit),
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
