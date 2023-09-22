// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';

class GelbooruProvider extends ConsumerWidget {
  const GelbooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruConfigProvider);

    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(gelbooruDownloadFileNameGeneratorProvider)),
        // artist/character posts
        postArtistCharacterRepoProvider.overrideWith(
            (ref) => ref.watch(gelbooruArtistCharacterPostRepoProvider)),
        // tags
        tagRepoProvider
            .overrideWith((ref) => ref.watch(gelbooruTagRepoProvider)),
        // post count
        if (booru.booruType == BooruType.gelbooru)
          postCountRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruPostCountRepoProvider))
        else
          postCountRepoProvider
              .overrideWith((ref) => ref.watch(emptyPostCountRepoProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final gelbooruClientProvider = Provider<GelbooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return GelbooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});
