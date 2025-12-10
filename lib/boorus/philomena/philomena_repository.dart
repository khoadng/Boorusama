// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/downloads/urls/types.dart';
import '../../core/posts/details/types.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/colors.dart';
import 'client_provider.dart';
import 'downloads/providers.dart';
import 'posts/providers.dart';
import 'tags/color.dart';
import 'tags/providers.dart';

class PhilomenaRepository extends BooruRepositoryDefault {
  const PhilomenaRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(philomenaPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.watch(philomenaAutoCompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(philomenaDioProvider(config));

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

  @override
  Dio dio(BooruConfigAuth config) {
    return ref.watch(philomenaDioProvider(config));
  }

  @override
  MediaUrlResolver mediaUrlResolver(BooruConfigAuth config) {
    return ref.watch(philomenaMediaUrlResolverProvider(config));
  }

  @override
  DownloadSourceProvider? downloadSource(BooruConfigAuth config) {
    return const PhilomenaDownloadSource();
  }
}
