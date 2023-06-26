// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/api/rule34xxx/rule34xxx_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/empty_tag_repository.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/autocomplete/autocomplete_providers.dart';
import 'package:boorusama/boorus/gelbooru/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/tags.dart';

class GelbooruProvider extends ConsumerWidget {
  const GelbooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        if (booru.booruType == BooruType.rule34xxx)
          postRepoProvider
              .overrideWith((ref) => ref.watch(rule34xxxPostRepoProvider))
        else
          postRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruPostRepoProvider)),
        if (booru.booruType == BooruType.rule34xxx)
          postArtistCharacterRepoProvider
              .overrideWith((ref) => ref.watch(rule34xxxPostRepoProvider))
        else
          postArtistCharacterRepoProvider.overrideWith(
              (ref) => ref.watch(gelbooruArtistCharacterPostRepoProvider)),
        if (booru.booruType == BooruType.rule34xxx)
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(rule34xxxAutocompleteRepoProvider))
        else
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(gelbooruAutocompleteRepoProvider)),
        if (booru.booruType == BooruType.rule34xxx)
          tagRepoProvider.overrideWithValue(EmptyTagRepository())
        else
          tagRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruTagRepoProvider)),
        if (booru.booruType == BooruType.gelbooru)
          postCountRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruPostCountRepoProvider))
        else
          postCountRepoProvider
              .overrideWithValue(const EmptyPostCountRepository()),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(gelbooruDownloadFileNameGeneratorProvider)),
      ],
      child: Builder(
        builder: builder,
      ),
    );
  }
}

final gelbooruApiProvider = Provider<GelbooruApi>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));

  return GelbooruApi(dio);
});

final rule34xxxApiProvider = Provider<Rule34xxxApi>((ref) {
  final booruConfig = ref.read(currentBooruConfigProvider);
  final dio = ref.read(dioProvider(booruConfig.url));

  return Rule34xxxApi(dio);
});
