// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final hydrusPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
      (ref, config) {
        final client = ref.watch(hydrusClientProvider(config.auth));
        final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

        Future<PostResult<HydrusPost>> getPosts(
          List<String> tags,
          int page, {
          int? limit,
          PostFetchOptions? options,
        }) async {
          final files = await client.getFiles(
            tags: tags,
            page: page,
            limit: limit,
          );

          final data = files.files
              .map(
                (e) => postDtoToPost(
                  e,
                  PostMetadata(
                    page: page,
                    search: tags.join(' '),
                    limit: limit,
                  ),
                ),
              )
              .toList()
              .toResult(
                total: files.count,
              );

          if (options?.cascadeRequest ?? true) {
            ref
                .read(favoritesProvider(config.auth).notifier)
                .preload(data.posts);
          }

          return data;
        }

        return PostRepositoryBuilder(
          tagComposer: tagComposer,
          getSettings: () async => ref.read(imageListingSettingsProvider),
          fetchSingle: (id, {options}) async {
            final numericId = id as NumericPostId?;

            if (numericId == null) return Future.value();

            final file = await client.getFile(numericId.value);

            return file != null ? postDtoToPost(file, null) : null;
          },
          fetch: getPosts,
        );
      },
    );
