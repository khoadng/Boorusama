// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/riverpod/riverpod.dart';
import '../../../../blacklists/providers.dart';
import '../../../../configs/config.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';

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
          );
    });
