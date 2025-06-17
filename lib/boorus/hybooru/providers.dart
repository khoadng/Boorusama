// Package imports:
import 'package:booru_clients/hybooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/autocompletes/autocompletes.dart';
import '../../core/configs/config.dart';
import '../../core/http/providers.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/search/queries/providers.dart';
import '../../core/settings/providers.dart';

final hybooruClientProvider = Provider.family<HybooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return HybooruClient(
      dio: dio,
      baseUrl: config.url,
    );
  },
);

final hybooruPostRepoProvider =
    Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final client = ref.watch(hybooruClientProvider(config.auth));

    return PostRepositoryBuilder(
      getComposer: () => ref.read(tagQueryComposerProvider(config)),
      fetchSingle: (id, {options}) async {
        final numericId = id as NumericPostId?;

        if (numericId == null) return Future.value(null);

        final post = await client.getPost(id: numericId.value);
        return post != null
            ? _postDtoToPost(post, null, config.auth.url)
            : null;
      },
      fetch: (tags, page, {limit, options}) async {
        final query = tags.isNotEmpty ? tags.join(' ') : null;
        final posts = await client.getPosts(
          query: query,
          page: page - 1,
          pageSize: limit,
        );
        return posts.posts
            .map(
              (e) => _postSummaryToPost(
                e,
                PostMetadata(
                  page: page,
                  search: tags.join(' '),
                  limit: limit,
                ),
                config.auth.url,
              ),
            )
            .toList()
            .toResult();
      },
      getSettings: () async => ref.read(imageListingSettingsProvider),
    );
  },
);

HybooruPost _postSummaryToPost(
  PostSummaryDto e,
  PostMetadata? metadata,
  String baseUrl,
) {
  return HybooruPost(
    id: e.id ?? 0,
    thumbnailImageUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    sampleImageUrl: _buildFileUrl(e, baseUrl),
    originalImageUrl: _buildFileUrl(e, baseUrl),
    tags: const {}, // PostSummary doesn't include tags
    rating: Rating.general, // No rating in summary
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: 0,
    duration: 0,
    fileSize: 0,
    format: e.extension ?? '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? e.sha256 ?? e.hash ?? '',
    videoThumbnailUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    videoUrl: _buildFileUrl(e, baseUrl),
    width: e.width?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(e.posted ?? ''),
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
  );
}

HybooruPost _postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
  String baseUrl,
) {
  return HybooruPost(
    id: e.id ?? 0,
    thumbnailImageUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    sampleImageUrl: _buildFileUrl(e, baseUrl),
    originalImageUrl: _buildFileUrl(e, baseUrl),
    tags: e.tags?.keys.toSet() ?? {},
    rating: _mapRating(e.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: e.relations?.isNotEmpty == true,
    source: PostSource.from(e.sources?.firstOrNull),
    score: 0,
    duration: e.duration?.toDouble() ?? 0,
    fileSize: e.size ?? 0,
    format: e.extension ?? '',
    hasSound: e.hasAudio,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? e.sha256 ?? e.hash ?? '',
    videoThumbnailUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    videoUrl: _buildFileUrl(e, baseUrl),
    width: e.width?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(e.posted ?? ''),
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
  );
}

String _buildFileUrl(dynamic post, String baseUrl, {bool thumbnail = false}) {
  final hash = post is PostDto
      ? (post.sha256 ?? post.hash)
      : post is PostSummaryDto
          ? (post.sha256 ?? post.hash)
          : null;
  final extension = post is PostDto
      ? post.extension
      : post is PostSummaryDto
          ? post.extension
          : null;

  if (hash == null) return '';

  // Remove trailing slash from baseUrl if present
  final cleanBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  if (thumbnail) {
    return '$cleanBaseUrl/files/t$hash.thumbnail';
  } else {
    return '$cleanBaseUrl/files/f$hash${extension ?? ''}';
  }
}

Rating _mapRating(double? rating) {
  if (rating == null) return Rating.general;

  // Map 0-1 rating to our enum
  if (rating >= 0.8) return Rating.explicit;
  if (rating >= 0.4) return Rating.questionable;
  return Rating.general;
}

final hybooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(hybooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query);

        return tags.map(
          (e) {
            final tagName = e.name ?? '';
            final parts = tagName.split(':');
            final category = parts.length > 1 ? parts[0] : 'general';
            final displayName = parts.length > 1 ? parts[1] : tagName;

            return AutocompleteData(
              label: displayName.toLowerCase().replaceAll('_', ' '),
              value: tagName.toLowerCase(),
              postCount: e.posts,
              category: category,
            );
          },
        ).toList();
      },
    );
  },
);

class HybooruPost extends SimplePost {
  HybooruPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.uploaderId,
    required super.createdAt,
    required super.uploaderName,
    required super.metadata,
  });
}
