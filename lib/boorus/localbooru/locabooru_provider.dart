// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

class LocalbooruProvider extends ConsumerWidget {
  const LocalbooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        downloadFileNameGeneratorProvider
            .overrideWith((ref) => DownloadUrlBaseNameFileNameGenerator()),
        postRepoProvider
            .overrideWith((ref) => ref.watch(zerochanPostRepoProvider)),
        // autocompleteRepoProvider
        //     .overrideWith((ref) => ref.watch(zerochanAutocompleteRepoProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final zerochanPostRepoProvider = Provider<PostRepository>((ref) {
  // final client = ref.watch(zerochanClientProvider);
  final settingsRepository = ref.watch(settingsRepoProvider);
  Directory? dir;

  return PostRepositoryBuilder(
    settingsRepository: settingsRepository,
    getPosts: (
      tags,
      page, {
      limit,
    }) =>
        TaskEither.Do(($) async {
      dir ??= await getDownloadsDirectory();

      final posts = await dir
              ?.list()
              .map((e) => SimplePost(
                    id: 0,
                    thumbnailImageUrl: e.path,
                    sampleImageUrl: e.path,
                    originalImageUrl: e.path,
                    tags: [],
                    rating: Rating.general,
                    hasComment: false,
                    isTranslated: false,
                    hasParentOrChildren: false,
                    source: PostSource.none(),
                    score: 0,
                    duration: 0,
                    fileSize: 0,
                    format: extension(e.path),
                    hasSound: null,
                    height: 0,
                    md5: '',
                    videoThumbnailUrl: '',
                    videoUrl: '',
                    width: 0,
                    getLink: (baseUrl) => '',
                  ))
              .toList() ??
          <Post>[];

      return posts;
    }),
  );
});

// final zerochanAutocompleteRepoProvider =
//     Provider<AutocompleteRepository>((ref) {
//   final client = ref.watch(zerochanClientProvider);

//   return AutocompleteRepositoryBuilder(autocomplete: (query) async {
//     final tags = await client.getAutocomplete(query: query);

//     return tags
//         .map((e) => AutocompleteData(
//               label: e.value?.toLowerCase() ?? '',
//               value: e.value?.toLowerCase() ?? '',
//               postCount: e.total,
//               category: e.type?.toLowerCase() ?? '',
//             ))
//         .toList();
//   });
// });
