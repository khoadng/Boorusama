// Package imports:
import 'package:booru_clients/nozomi.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/types.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/create.dart';
import '../../core/downloads/filename/types.dart';
import '../../core/images/types.dart';
import '../../core/posts/listing/types.dart';
import '../../core/posts/post/types.dart';
import '../../core/tags/autocompletes/types.dart';
import '../../core/tags/tag/types.dart';
import 'client_provider.dart';
import 'posts/providers.dart';
import 'tags/providers.dart';

const kNozomiCustomDownloadFileNameFormat = '{id}_{width}x{height}.{extension}';

class NozomiRepository extends BooruRepositoryDefault {
  const NozomiRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.read(nozomiPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.read(nozomiAutocompleteRepoProvider(config));
  }

  @override
  TagExtractor tagExtractor(BooruConfigAuth config) {
    return ref.watch(nozomiTagExtractorProvider(config));
  }

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator(BooruConfigAuth config) {
    return const DefaultGridThumbnailUrlGenerator(
      mediaMapper: _nozomiGridThumbnailMedia,
      loadingPlaceholderAspectRatioResolver:
          _nozomiLoadingPlaceholderAspectRatio,
    );
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(nozomiDioProvider(config));

    return () => NozomiClient(
      dio: dio,
      baseUrl: config.url,
    ).getPosts(limit: 1).then((value) => true);
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) {
    return NozomiPostLinkGenerator(baseUrl: config.url);
  }

  @override
  Map<String, String> extraHttpHeaders(BooruConfigAuth config) {
    return {
      'Referer': 'https://nozomi.la/',
    };
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kNozomiCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kNozomiCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      hasMd5: false,
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
    return ref.watch(nozomiDioProvider(config));
  }
}

GridThumbnailMedia _nozomiGridThumbnailMedia(
  Post post,
  GridThumbnailSettings settings,
) {
  final media = defaultGridThumbnailMedia(post, settings);

  return GridThumbnailMedia(
    url: media.url,
    aspectRatio: media.aspectRatio,
    placeholderAspectRatio: media.placeholderAspectRatio,
    placeholderFit: media.placeholderFit,
  );
}

double? _nozomiLoadingPlaceholderAspectRatio(GridThumbnailSettings settings) {
  return switch (settings.imageQuality) {
    ImageQuality.automatic || ImageQuality.low => 1,
    ImageQuality.high || ImageQuality.highest => switch (settings.gridSize) {
      GridSize.micro || GridSize.tiny => 1,
      _ => null,
    },
    ImageQuality.original => null,
  };
}

class NozomiPostLinkGenerator<T extends Post> implements PostLinkGenerator<T> {
  const NozomiPostLinkGenerator({
    required this.baseUrl,
  });

  final String baseUrl;

  @override
  String getLink(T post) {
    final url = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$url/post/${post.id}.html';
  }
}
