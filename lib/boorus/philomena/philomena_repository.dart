// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/engine/engine.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/colors.dart';
import '../../core/theme.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

class PhilomenaRepository extends BooruRepositoryDefault {
  const PhilomenaRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.watch(philomenaPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.watch(philomenaAutoCompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => PhilomenaClient(
          baseUrl: config.url,
          dio: dio,
          apiKey: config.apiKey,
        ).getImages(tags: ['*']).then((value) => true);
  }

  @override
  PostLinkGenerator postLinkGenerator(BooruConfigAuth config) {
    return ImagePostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const PhilomenaTagColorGenerator();
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      hasRating: false,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
      ],
    );
  }
}

class PhilomenaTagColorGenerator implements TagColorGenerator {
  const PhilomenaTagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    return switch (options.tagType) {
      'error' => options.colors.get('error'),
      'rating' => options.colors.get('rating'),
      'origin' => options.colors.get('origin'),
      'oc' => options.colors.get('oc'),
      'character' => options.colors.character,
      'species' => options.colors.get('species'),
      'content-official' => options.colors.get('content-official'),
      'content-fanmade' => options.colors.get('content-fanmade'),
      _ => options.colors.general,
    };
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return options.brightness.isDark
        ? const TagColors(
            general: Colors.green,
            character: Color.fromARGB(255, 73, 170, 190),
            customColors: {
              'error': Color.fromARGB(255, 212, 84, 96),
              'rating': Color.fromARGB(255, 64, 140, 217),
              'origin': Color.fromARGB(255, 111, 100, 224),
              'oc': Color.fromARGB(255, 176, 86, 182),
              'species': Color.fromARGB(255, 176, 106, 80),
              'content-official': Color.fromARGB(255, 185, 180, 65),
              'content-fanmade': Color.fromARGB(255, 204, 143, 180),
            },
          )
        : const TagColors(
            general: Color.fromARGB(255, 111, 143, 13),
            character: Color.fromARGB(255, 46, 135, 119),
            customColors: {
              'error': Color.fromARGB(255, 173, 38, 63),
              'rating': Color.fromARGB(255, 65, 124, 169),
              'origin': Color.fromARGB(255, 56, 62, 133),
              'oc': Color.fromARGB(255, 176, 86, 182),
              'species': Color.fromARGB(255, 131, 87, 54),
              'content-official': Color.fromARGB(255, 151, 142, 27),
              'content-fanmade': Color.fromARGB(255, 174, 90, 147),
            },
          );
  }
}
