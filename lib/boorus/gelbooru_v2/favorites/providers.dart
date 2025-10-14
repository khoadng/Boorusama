// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/types.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import '../gelbooru_v2_provider.dart';
import '../posts/providers.dart';
import '../posts/repo.dart';
import '../posts/types.dart';
import '../tags/providers.dart';

final gelbooruV2FavoritesPostRepoProvider =
    Provider.family<
      PostRepository<GelbooruV2Post>,
      (BooruConfigSearch, String uuid)
    >(
      (ref, params) {
        final (config, uuid) = params;
        final client = ref.watch(gelbooruV2ClientProvider(config.auth));
        final tagComposer = ref.watch(
          gelbooruV2TagQueryComposerProvider(config),
        );
        final imageUrlResolver = ref.watch(
          gelbooruV2PostImageUrlResolverProvider,
        );
        final gelbooruV2 = ref.watch(gelbooruV2Provider);
        final favCapabilities = gelbooruV2
            .getCapabilitiesForSite(config.auth.url)
            ?.favorites;
        final paginationType = PaginationType.parse(
          favCapabilities?.paginationType,
        );

        return GelbooruV2PostRepository(
          fetcher: (tags, page, {limit, options}) => client.getFavorites(
            page: page,
            uid: uuid,
            paginationType: paginationType,
            fixedLimit: favCapabilities?.fixedLimit,
          ),
          fetchSingle: (id, {options}) => client.getPost(id),
          imageUrlResolver: imageUrlResolver,
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
        );
      },
    );

final gelbooruV2FavoriteRepoProvider =
    Provider.family<FavoriteRepository<GelbooruV2Post>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(gelbooruV2ClientProvider(config));

        return FavoriteRepositoryBuilder(
          add: (postId) => client
              .addFavorite(postId: postId)
              .then(
                (value) => switch (value) {
                  GelbooruFavoriteStatus.success => AddFavoriteStatus.success,
                  GelbooruFavoriteStatus.alreadyFavorited =>
                    AddFavoriteStatus.alreadyExists,
                  _ => AddFavoriteStatus.failure,
                },
              ),
          remove: (postId) => client
              .removeFavorite(postId: postId)
              .then((value) => true)
              .catchError((e) => false),
          isFavorited: (post) => false,
          canFavorite: () => client.canFavorite,
        );
      },
    );
