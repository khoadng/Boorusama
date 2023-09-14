// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/api/gelbooru/gelbooru_v0.2_api.dart';
import 'package:boorusama/api/rule34xxx/rule34xxx_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
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
    // This is a bit inconsistent, but it's the best I can do for now since there are just too many forks of Gelbooru
    // I can't use currrentBooruProvider because it doesn't have the booru type hint
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final booruFactory = ref.watch(booruFactoryProvider);
    final booruTypeHint = intToBooruType(booruConfig.booruIdHint);
    final booru = booruConfig.createBooruFrom(booruFactory);

    return ProviderScope(
      overrides: [
        bulkDownloadFileNameProvider
            .overrideWithValue(Md5OnlyFileNameGenerator()),
        downloadFileNameGeneratorProvider.overrideWith(
            (ref) => ref.watch(gelbooruDownloadFileNameGeneratorProvider)),
        // posts
        if (booru.booruType == BooruType.rule34xxx)
          postRepoProvider
              .overrideWith((ref) => ref.watch(rule34xxxPostRepoProvider))
        else if (booru.booruType == BooruType.unknown &&
            booruTypeHint == BooruType.rule34xxx)
          postRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruV2dot0PostRepoProvider))
        else
          postRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruPostRepoProvider)),
        // artist/character posts
        if (booru.booruType == BooruType.gelbooru)
          postArtistCharacterRepoProvider.overrideWith(
              (ref) => ref.watch(gelbooruArtistCharacterPostRepoProvider))
        else
          postArtistCharacterRepoProvider
              .overrideWith((ref) => ref.watch(rule34xxxPostRepoProvider)),
        // autocomplete
        if (booru.booruType == BooruType.gelbooru)
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(gelbooruAutocompleteRepoProvider))
        else if (booru.booruType == BooruType.unknown &&
            booruTypeHint == BooruType.rule34xxx)
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(gelbooruV0Dot2AutocompleteRepoProvider))
        else
          autocompleteRepoProvider.overrideWith(
              (ref) => ref.watch(rule34xxxAutocompleteRepoProvider)),
        // tags
        if (booru.booruType == BooruType.gelbooru)
          tagRepoProvider
              .overrideWith((ref) => ref.watch(gelbooruTagRepoProvider))
        else
          tagRepoProvider
              .overrideWith((ref) => ref.watch(emptyTagRepoProvider)),
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

final gelbooruApiProvider = Provider<GelbooruApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return GelbooruApi(dio);
});

final rule34xxxApiProvider = Provider<Rule34xxxApi>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return Rule34xxxApi(dio);
});

final gelbooruV2dot0ApiProvider = Provider<GelbooruV0dot2Api>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return GelbooruV0dot2Api(dio);
});
