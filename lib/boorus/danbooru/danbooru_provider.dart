// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
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
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
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
    required this.postRepo,
    required this.poolRepo,
    required this.userRepo,
    required this.autocompleteRepo,
    required this.relatedTagRepo,
    required this.wikiRepo,
    required this.poolDescriptionRepo,
    required this.exploreRepo,
    required this.savedSearchRepo,
    required this.favoriteTagsRepo,
    required this.tagInfo,
    required this.currentBooruConfigRepository,
    required this.fileNameGenerator,
    required this.poolOverviewBloc,
    required this.tagBloc,
    required this.wikiBloc,
    required this.savedSearchBloc,
    required this.profileCubit,
    required this.danbooruArtistCharacterPostRepository,
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
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();

    final fileNameGenerator = BoorusamaStyledFileNameGenerator();

    final tagRepo = TagRepositoryApi(api, currentBooruConfigRepo);

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

    final userRepo = UserRepositoryApi(
      api,
      currentBooruConfigRepo,
      tagInfo.defaultBlacklistedTags,
    );

    final poolRepo = PoolCacher(PoolRepositoryApi(api, currentBooruConfigRepo));

    final autocompleteRepo = AutocompleteRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepo,
    );

    final relatedTagRepo = RelatedTagRepositoryEmpty();

    final wikiRepo = WikiRepositoryApi(api);

    final poolDescriptionRepo = PoolDescriptionRepositoryApi(
      dio: dio,
      endpoint: booruConfig.url,
    );

    final savedSearchRepo =
        SavedSearchRepositoryApi(api, currentBooruConfigRepo);

    final favoriteTagRepo = context.read<FavoriteTagRepository>();

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

    final artistCharacterPostRepository = DanbooruArtistCharacterPostRepository(
      repository: postRepo,
      cache: LruCacher(),
    );

    return DanbooruProvider(
      builder: builder,
      currentBooruConfigRepo: currentBooruConfigRepo,
      autocompleteRepo: autocompleteRepo,
      exploreRepo: exploreRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
      postRepo: postRepo,
      profileRepo: profileRepo,
      relatedTagRepo: relatedTagRepo,
      savedSearchRepo: savedSearchRepo,
      settingRepository: settingRepository,
      tagRepo: tagRepo,
      userRepo: userRepo,
      wikiRepo: wikiRepo,
      favoriteTagsRepo: favoriteTagRepo,
      currentBooruConfigRepository: currentBooruConfigRepo,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      poolOverviewBloc: poolOverviewBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      profileCubit: profileCubit,
      danbooruArtistCharacterPostRepository: artistCharacterPostRepository,
    );
  }

  factory DanbooruProvider.of(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
  }) {
    final settingRepository = context.read<SettingsRepository>();
    final tagRepo = context.read<TagRepository>();
    final profileRepo = context.read<ProfileRepository>();
    final postRepo = context.read<DanbooruPostRepository>();
    final exploreRepo = context.read<ExploreRepository>();
    final userRepo = context.read<UserRepository>();
    final poolRepo = context.read<PoolRepository>();
    final autocompleteRepo = context.read<AutocompleteRepository>();
    final relatedTagRepo = context.read<RelatedTagRepository>();
    final wikiRepo = context.read<WikiRepository>();
    final poolDescriptionRepo = context.read<PoolDescriptionRepository>();
    final savedSearchRepo = context.read<SavedSearchRepository>();
    final currentBooruConfigRepo = context.read<CurrentBooruConfigRepository>();
    final favoriteTagRepo = context.read<FavoriteTagRepository>();
    final fileNameGenerator = context.read<FileNameGenerator>();

    final tagInfo = context.read<TagInfo>();

    final poolOverviewBloc = context.read<PoolOverviewBloc>();
    final tagBloc = context.read<TagBloc>();
    final wikiBloc = context.read<WikiBloc>();
    final savedSearchBloc = context.read<SavedSearchBloc>();
    final profileCubit = context.read<ProfileCubit>();
    final artistCharacterPostRepository =
        context.read<DanbooruArtistCharacterPostRepository>();

    return DanbooruProvider(
      builder: builder,
      currentBooruConfigRepo: currentBooruConfigRepo,
      autocompleteRepo: autocompleteRepo,
      exploreRepo: exploreRepo,
      poolDescriptionRepo: poolDescriptionRepo,
      poolRepo: poolRepo,
      postRepo: postRepo,
      profileRepo: profileRepo,
      relatedTagRepo: relatedTagRepo,
      savedSearchRepo: savedSearchRepo,
      settingRepository: settingRepository,
      tagRepo: tagRepo,
      userRepo: userRepo,
      wikiRepo: wikiRepo,
      favoriteTagsRepo: favoriteTagRepo,
      currentBooruConfigRepository: currentBooruConfigRepo,
      tagInfo: tagInfo,
      fileNameGenerator: fileNameGenerator,
      poolOverviewBloc: poolOverviewBloc,
      tagBloc: tagBloc,
      wikiBloc: wikiBloc,
      savedSearchBloc: savedSearchBloc,
      profileCubit: profileCubit,
      danbooruArtistCharacterPostRepository: artistCharacterPostRepository,
    );
  }

  final Widget Function(BuildContext context) builder;

  final TagRepository tagRepo;
  final ProfileRepository profileRepo;
  final CurrentBooruConfigRepository currentBooruConfigRepo;
  final SettingsRepository settingRepository;
  final DanbooruPostRepository postRepo;
  final DanbooruArtistCharacterPostRepository
      danbooruArtistCharacterPostRepository;
  final PoolRepository poolRepo;
  final UserRepository userRepo;
  final AutocompleteRepository autocompleteRepo;
  final RelatedTagRepository relatedTagRepo;
  final WikiRepository wikiRepo;
  final PoolDescriptionRepository poolDescriptionRepo;
  final ExploreRepository exploreRepo;
  final SavedSearchRepository savedSearchRepo;
  final FavoriteTagRepository favoriteTagsRepo;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final FileNameGenerator fileNameGenerator;

  final PoolOverviewBloc poolOverviewBloc;
  final TagBloc tagBloc;
  final WikiBloc wikiBloc;
  final SavedSearchBloc savedSearchBloc;
  final ProfileCubit profileCubit;

  final TagInfo tagInfo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tagRepo),
        RepositoryProvider.value(value: profileRepo),
        RepositoryProvider.value(value: currentBooruConfigRepo),
        RepositoryProvider.value(value: settingRepository),
        RepositoryProvider.value(value: postRepo),
        RepositoryProvider.value(value: danbooruArtistCharacterPostRepository),
        RepositoryProvider.value(value: poolRepo),
        RepositoryProvider.value(value: userRepo),
        RepositoryProvider.value(value: autocompleteRepo),
        RepositoryProvider.value(value: relatedTagRepo),
        RepositoryProvider.value(value: wikiRepo),
        RepositoryProvider.value(value: poolDescriptionRepo),
        RepositoryProvider.value(value: exploreRepo),
        RepositoryProvider.value(value: savedSearchRepo),
        RepositoryProvider.value(value: fileNameGenerator),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profileCubit),
          BlocProvider.value(value: poolOverviewBloc),
          BlocProvider.value(value: tagBloc),
          BlocProvider.value(value: wikiBloc),
          BlocProvider.value(value: savedSearchBloc),
        ],
        child: ProviderScope(
          overrides: [
            autocompleteRepoProvider.overrideWithValue(autocompleteRepo),
            poolRepoProvider.overrideWithValue(poolRepo),
            danbooruArtistCharacterPostRepoProvider
                .overrideWithValue(danbooruArtistCharacterPostRepository),
            poolDescriptionRepoProvider.overrideWithValue(poolDescriptionRepo),
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
