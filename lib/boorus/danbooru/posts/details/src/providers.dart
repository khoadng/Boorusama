// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/details/types.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/settings/providers.dart';
import '../../../../../foundation/riverpod/riverpod.dart';
import '../../../pools/pool/providers.dart';
import '../../../pools/pool/types.dart';
import '../../../users/creator/providers.dart';
import '../../post/providers.dart';
import '../../post/types.dart';
import 'media_url_resolver.dart';

final danbooruPostDetailsChildrenProvider = FutureProvider.family
    .autoDispose<
      List<DanbooruPost>,
      (BooruConfigFilter, BooruConfigSearch, DanbooruPost)
    >((ref, params) {
      ref.cacheFor(const Duration(seconds: 60));

      final (filter, search, post) = params;

      if (!post.hasParentOrChildren) return [];

      return ref
          .watch(danbooruPostRepoProvider(search))
          .getPostsFromTagWithBlacklist(
            tag: post.relationshipQuery,
            blacklist: ref.watch(blacklistTagsProvider(filter).future),
            softLimit: null,
          );
    });

final danbooruPostDetailsPoolsProvider = FutureProvider.family
    .autoDispose<List<DanbooruPool>, (BooruConfigAuth, int)>((
      ref,
      params,
    ) {
      final (config, postId) = params;
      final repo = ref.watch(danbooruPoolRepoProvider(config));

      return repo.getPoolsByPostId(postId);
    });

final danbooruMediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) => DanbooruMediaUrlResolver(
        imageQuality: ref.watch(
          settingsProvider.select((value) => value.listing.imageQuality),
        ),
      ),
    );

final danbooruUploaderQueryProvider =
    Provider.family<UploaderQuery?, DanbooruPost>((ref, post) {
      final uploader = ref.watch(danbooruCreatorProvider(post.uploaderId));

      return switch (uploader) {
        final uploader? => UserColonUploaderQuery(uploader.name),
        _ => null,
      };
    });
