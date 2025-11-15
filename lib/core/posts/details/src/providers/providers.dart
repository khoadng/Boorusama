// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/riverpod/riverpod.dart';
import '../../../../blacklists/providers.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../settings/providers.dart';
import '../../../post/providers.dart';
import '../../../post/types.dart';
import '../types/media_url_resolver.dart';

final singlePostDetailsProvider = FutureProvider.autoDispose
    .family<Post?, (PostId, BooruConfigSearch)>((ref, params) async {
      final (id, config) = params;

      final postRepo = ref.watch(postRepoProvider(config));

      final result = await postRepo.getPost(id).run();

      return result.getOrElse((_) => null);
    });

final detailsArtistPostsProvider = FutureProvider.autoDispose
    .family<List<Post>, (BooruConfigFilter, BooruConfigSearch, String?)>((
      ref,
      params,
    ) {
      ref.cacheFor(const Duration(seconds: 30));

      final (filter, search, artistName) = params;
      return ref
          .watch(postRepoProvider(search))
          .getPostsFromTagWithBlacklist(
            tag: artistName,
            blacklist: ref.watch(blacklistTagsProvider(filter).future),
            options: PostFetchOptions.raw,
            softLimit: null,
          );
    });

final mediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) {
        final fallbackMediaUrlResolver = ref.watch(
          defaultMediaUrlResolverProvider(config),
        );

        final mediaUrlResolver =
            ref.watch(booruRepoProvider(config))?.mediaUrlResolver(config) ??
            fallbackMediaUrlResolver;

        return mediaUrlResolver;
      },
    );

final defaultMediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) => DefaultMediaUrlResolver(
        imageQuality: ref.watch(
          settingsProvider.select((value) => value.listing.imageQuality),
        ),
      ),
    );

final sampleMediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) => const SampleMediaUrlResolver(),
    );
