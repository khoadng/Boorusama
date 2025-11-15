// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/details/types.dart';
import '../../../core/posts/post/providers.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/search/queries/providers.dart';
import '../../../core/settings/providers.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final philomenaPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>((ref, config) {
      final client = ref.watch(philomenaClientProvider(config.auth));
      final tagComposer = ref.watch(defaultTagQueryComposerProvider(config));

      return PostRepositoryBuilder(
        tagComposer: tagComposer,
        getSettings: () async => ref.read(imageListingSettingsProvider),
        fetchSingle: (id, {options}) async {
          final numericId = id as NumericPostId?;

          if (numericId == null) return Future.value();

          final post = await client.getImage(numericId.value);

          return post != null ? postDtoToPost(post, null) : null;
        },
        fetch: (tags, page, {limit, options}) async {
          final isEmpty = tags.join(' ').isEmpty;

          final posts = await client.getImages(
            tags: isEmpty ? ['*'] : tags,
            page: page,
            perPage: limit,
          );

          return posts.images
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
              .toResult(total: posts.count);
        },
      );
    });

final philomenaMediaUrlResolverProvider =
    Provider.family<MediaUrlResolver, BooruConfigAuth>(
      (ref, config) => PhilomenaMediaUrlResolver(
        imageQuality: ref.watch(
          settingsProvider.select((value) => value.listing.imageQuality),
        ),
      ),
    );

final philomenaUploaderQueryProvider =
    Provider.family<UploaderQuery?, PhilomenaPost>((ref, post) {
      return switch (post.uploaderName) {
        final uploader? => UploaderColonUploaderQuery(uploader),
        _ => null,
      };
    });
