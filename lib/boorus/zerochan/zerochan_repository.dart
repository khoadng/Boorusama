// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/zerochan.dart';
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
import '../../core/tags/tag/tag.dart';
import 'client_provider.dart';
import 'posts/providers.dart';
import 'tags/parser.dart';
import 'tags/providers.dart';

const kZerochanCustomDownloadFileNameFormat =
    '{id}_{width}x{height}.{extension}';

class ZerochanRepository extends BooruRepositoryDefault {
  const ZerochanRepository({required this.ref});

  @override
  final Ref ref;

  @override
  PostRepository<Post> post(BooruConfigSearch config) {
    return ref.watch(zerochanPostRepoProvider(config));
  }

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) {
    return ref.watch(zerochanAutoCompleteRepoProvider(config));
  }

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) {
    final dio = ref.watch(dioProvider(config));

    return () => ZerochanClient(dio: dio, baseUrl: config.url)
        .getPosts(strict: true)
        .then((value) => true);
  }

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) {
    return DirectIdPathPostLinkGenerator(baseUrl: config.url);
  }

  @override
  TagColorGenerator tagColorGenerator() {
    return const ZerochanTagColorGenerator();
  }

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) {
    final client = ref.watch(zerochanClientProvider(config));

    return DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kZerochanCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kZerochanCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      hasMd5: false,
      hasRating: false,
      tokenHandlers: [
        WidthTokenHandler(),
        HeightTokenHandler(),
        AspectRatioTokenHandler(),
      ],
      asyncTokenHandlers: [
        AsyncTokenHandler(
          ClassicTagsTokenResolver(
            tagFetcher: (post) async {
              final tags = await client.getTagsFromPostId(postId: post.id);

              return tags
                  .map(
                    (tag) => (
                      name: normalizeZerochanTag(tag.value) ?? '???',
                      type: zerochanStringToTagCategory(tag.type).name,
                    ),
                  )
                  .toList();
            },
          ),
        ),
      ],
    );
  }

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) {
    return ref.watch(zerochanTagGroupRepoProvider(config));
  }
}

class ZerochanTagColorGenerator implements TagColorGenerator {
  const ZerochanTagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    final colors = options.colors;

    return switch (options.tagType) {
      'mangaka' ||
      'studio' ||
      // This is from a fallback in case the tag is already searched in other boorus
      'artist' =>
        colors.artist,
      'source' ||
      'game' ||
      'visual_novel' ||
      'series' ||
      // This is from a fallback in case the tag is already searched in other boorus
      'copyright' =>
        colors.copyright,
      'character' => colors.character,
      'meta' => colors.meta,
      _ => colors.general,
    };
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return TagColors.fromBrightness(options.brightness);
  }
}
