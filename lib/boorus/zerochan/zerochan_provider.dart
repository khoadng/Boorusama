// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/zerochan/types/types.dart';
import 'package:boorusama/clients/zerochan/zerochan_client.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

final zerochanClientProvider = Provider<ZerochanClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return ZerochanClient(dio: dio);
});

final zerochanPostRepoProvider = Provider<PostRepository>((ref) {
  final client = ref.watch(zerochanClientProvider);
  final settingsRepository = ref.watch(settingsRepoProvider);

  return PostRepositoryBuilder(
    settingsRepository: settingsRepository,
    getPosts: (
      tags,
      page, {
      limit,
    }) =>
        TaskEither.Do(($) async {
      final posts = await client.getPosts(
        tags: tags.split(' ').toList(),
        page: page,
        limit: limit,
      );

      return posts
          .map((e) => SimplePost(
                id: e.id ?? 0,
                thumbnailImageUrl: e.thumbnail ?? '',
                sampleImageUrl: e.thumbnail ?? '',
                originalImageUrl: e.fileUrl() ?? '',
                tags: e.tags ?? [],
                rating: Rating.general,
                hasComment: false,
                isTranslated: false,
                hasParentOrChildren: false,
                source: PostSource.from(e.source),
                score: 0,
                duration: 0,
                fileSize: 0,
                format: extension(e.thumbnail ?? ''),
                hasSound: null,
                height: e.height?.toDouble() ?? 0,
                md5: '',
                videoThumbnailUrl: '',
                videoUrl: '',
                width: e.width?.toDouble() ?? 0,
                getLink: (baseUrl) => baseUrl.endsWith('/')
                    ? '$baseUrl${e.id}'
                    : '$baseUrl/${e.id}',
              ))
          .toList();
    }),
  );
});

final zerochanAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final client = ref.watch(zerochanClientProvider);

  return AutocompleteRepositoryBuilder(autocomplete: (query) async {
    final tags = await client.getAutocomplete(query: query);

    return tags
        .map((e) => AutocompleteData(
              label: e.value?.toLowerCase() ?? '',
              value: e.value?.toLowerCase() ?? '',
              postCount: e.total,
              category: e.type?.toLowerCase() ?? '',
            ))
        .toList();
  });
});
