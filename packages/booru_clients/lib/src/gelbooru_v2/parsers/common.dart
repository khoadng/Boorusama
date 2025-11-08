import 'dart:developer';

import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../common/feature.dart';
import '../post_v2_dto.dart';

class FavoriteHtmlPostDetailsData {
  const FavoriteHtmlPostDetailsData({
    required this.id,
    required this.score,
    required this.rating,
    required this.source,
    required this.owner,
  });

  final int id;
  final int? score;
  final String? rating;
  final String? source;
  final String? owner;

  factory FavoriteHtmlPostDetailsData.fromDocument(
    Document document,
    String html,
    Map<String, dynamic> context,
  ) {
    return FavoriteHtmlPostDetailsData(
      id: _extractPostId(context),
      score: _extractScore(document),
      rating: _extractRating(document),
      source: _extractSource(document),
      owner: _extractOwner(document),
    );
  }

  static int _extractPostId(Map<String, dynamic> context) {
    final postId = context[P.postId];

    final value = switch (postId) {
      int id when id > 0 => id,
      String idString => int.tryParse(idString) ?? -1,
      _ => -1,
    };

    if (value > 0) return value;
    throw ArgumentError('Invalid post ID in context: $postId');
  }

  static int? _extractScore(Document document) {
    // Try statistics section
    final statsItems = document.querySelectorAll('#stats li');
    for (final item in statsItems) {
      final text = item.text.trim();
      final scoreMatch = RegExp(r'Score:\s*(-?\d+)').firstMatch(text);
      if (scoreMatch != null) {
        return int.tryParse(scoreMatch.group(1)!);
      }
    }
    return null;
  }

  static String? _extractRating(Document document) {
    // Try statistics section
    final statsItems = document.querySelectorAll('#stats li');
    for (final item in statsItems) {
      final text = item.text.trim();
      final ratingMatch = RegExp(
        r'Rating:\s*(\w+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (ratingMatch != null) {
        final rating = ratingMatch.group(1)!.toLowerCase();
        return switch (rating) {
          'explicit' => 'e',
          'questionable' => 'q',
          'safe' => 's',
          _ => rating[0],
        };
      }
    }

    // Fallback: try edit form radio buttons
    final explicitRadio = document.querySelector('#rating_e[checked]');
    if (explicitRadio != null) return 'e';

    final questionableRadio = document.querySelector('#rating_q[checked]');
    if (questionableRadio != null) return 'q';

    return null;
  }

  static String? _extractSource(Document document) {
    // Try statistics section first
    final statsItems = document.querySelectorAll('#stats li');
    for (final item in statsItems) {
      final text = item.text.trim();
      if (text.startsWith('Source:')) {
        final link = item.querySelector('a');
        return link?.attributes['href']?.trim();
      }
    }

    // Try edit form input
    final sourceInput = document.querySelector('input[name="source"]');
    if (sourceInput != null) {
      final value = sourceInput.attributes['value']?.trim();
      return value?.isNotEmpty == true ? value : null;
    }

    return null;
  }

  static String? _extractOwner(Document document) {
    // Try statistics section
    final statsItems = document.querySelectorAll('#stats li');
    for (final item in statsItems) {
      final text = item.text.trim();
      final userMatch = RegExp(
        r'(?:by|By)\s+(.+)',
        multiLine: true,
      ).firstMatch(text);
      if (userMatch != null) {
        final link = item.querySelector('a');
        return link?.text.trim() ?? userMatch.group(1)!.trim();
      }
    }
    return null;
  }
}

class ExtractedPostData {
  const ExtractedPostData({
    required this.id,
    required this.tags,
    required this.rating,
    required this.score,
    required this.user,
  });

  final int id;
  final List<String> tags;
  final String rating;
  final int score;
  final String user;
}

class PostsDataExtractor {
  const PostsDataExtractor({
    required this.regex,
    required this.bodyParser,
  });

  final RegExp regex;
  final ExtractedPostData Function(int id, String body) bodyParser;

  Map<int, ExtractedPostData> extractPostsData(String htmlContent) {
    final postsData = <int, ExtractedPostData>{};

    for (final match in regex.allMatches(htmlContent)) {
      final id = int.parse(match.group(1)!);
      final body = match.group(2)!;

      postsData[id] = bodyParser(id, body);
    }

    return postsData;
  }
}

class FavoritedHtmlPostData {
  const FavoritedHtmlPostData({
    required this.id,
    required this.thumbUrl,
    required this.tags,
    required this.rating,
    required this.score,
    required this.user,
  });

  final int id;
  final String thumbUrl;
  final List<String> tags;
  final String rating;
  final int score;
  final String user;

  static FavoritedHtmlPostData fromElementAndData(
    Element element,
    Map<int, ExtractedPostData> postsData,
  ) {
    final id = _extractPostId(element);
    final thumbUrl = _extractThumbUrl(element);

    final data = postsData[id];
    if (data == null) throw ArgumentError('No data found for post ID: $id');

    return FavoritedHtmlPostData(
      id: id,
      thumbUrl: thumbUrl,
      tags: data.tags,
      rating: data.rating,
      score: data.score,
      user: data.user,
    );
  }

  static int _extractPostId(Element element) {
    final href = element.attributes['href'] ?? "";
    final idMatch = RegExp(r'id=(\d+)').firstMatch(href);
    if (idMatch == null) throw ArgumentError('Invalid href: no ID found');
    return int.parse(idMatch.group(1)!);
  }

  static String _extractThumbUrl(Element element) {
    final url = element.querySelector('img')?.attributes['src'] ?? "";
    return ensureValidUrl(url) ?? "";
  }
}

PostV2Dto toDto(FavoritedHtmlPostData data) {
  final thumbUrl = normalizeUrl(data.thumbUrl);
  return PostV2Dto(
    id: data.id,
    previewUrl: thumbUrl,
    sampleUrl: thumbUrl,
    fileUrl: thumbUrl,
    tags: data.tags.join(' '),
    rating: data.rating,
    score: data.score,
    owner: data.user,
  );
}

GelbooruV2Posts parseFavoritePostsHtml(
  Response response,
  Map<String, dynamic> context, {
  required PostsDataExtractor dataExtractor,
}) {
  final htmlContent = response.data;
  final doc = parse(htmlContent);

  final postsData = dataExtractor.extractPostsData(htmlContent);
  final elements = doc.querySelectorAll('span.thumb a');
  final posts = <FavoritedHtmlPostData>[];

  for (final a in elements) {
    try {
      final post = FavoritedHtmlPostData.fromElementAndData(a, postsData);
      posts.add(post);
    } catch (e) {
      // Skip invalid posts
      continue;
    }
  }

  return GelbooruV2Posts(
    posts: posts.map((post) => toDto(post)).toList(),
    count: null,
  );
}

String convertRating(String rating) {
  return switch (rating.toLowerCase()) {
    'explicit' => 'e',
    'questionable' => 'q',
    'safe' => 's',
    _ => rating.toLowerCase().isNotEmpty ? rating.toLowerCase()[0] : '',
  };
}

String? ensureValidUrl(String? url) {
  if (url == null || url.isEmpty) return url;

  if (url.startsWith('//')) {
    return 'https:$url';
  }

  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://$url';
  }
  return url;
}

class HtmlImageUrls {
  const HtmlImageUrls({
    this.fileUrl,
    this.sampleUrl,
    this.previewUrl,
    this.hash,
    this.directory,
  });

  final String? fileUrl;
  final String? sampleUrl;
  final String? previewUrl;
  final String? hash;
  final String? directory;

  factory HtmlImageUrls.fromDocument(
    Document document,
    String baseUrl,
    String html, {
    required HtmlImageExtractor extractor,
  }) {
    final fileUrl = extractor.extractOriginalImageUrl(document);
    final sampleUrl = extractor.extractSampleImageUrl(document);
    final previewUrl = extractor.extractPreviewImageUrl(document);

    final cleanedUrls = _cleanUrls(fileUrl, sampleUrl, previewUrl);
    final hash = extractor.extractHash(cleanedUrls.fileUrl, html);
    final directory = extractor.extractDirectory(cleanedUrls.fileUrl, html);

    return HtmlImageUrls(
      fileUrl: cleanedUrls.fileUrl,
      sampleUrl: cleanedUrls.sampleUrl,
      previewUrl: cleanedUrls.previewUrl,
      hash: hash,
      directory: directory,
    );
  }

  static ({String? fileUrl, String? sampleUrl, String? previewUrl}) _cleanUrls(
    String? fileUrl,
    String? sampleUrl,
    String? previewUrl,
  ) {
    final cleanedFileUrl = fileUrl != null ? normalizeUrl(fileUrl) : null;
    final cleanedSampleUrl = sampleUrl != null ? normalizeUrl(sampleUrl) : null;
    final cleanedPreviewUrl = previewUrl != null
        ? normalizeUrl(previewUrl)
        : null;

    final finalFileUrl = cleanedFileUrl ?? cleanedSampleUrl;
    final finalSampleUrl = cleanedSampleUrl ?? finalFileUrl;

    return (
      fileUrl: finalFileUrl,
      sampleUrl: finalSampleUrl,
      previewUrl: cleanedPreviewUrl,
    );
  }
}

abstract class HtmlImageExtractor {
  String? extractOriginalImageUrl(Document document);
  String? extractSampleImageUrl(Document document);
  String? extractPreviewImageUrl(Document document);
  String? extractHash(String? fileUrl, String html);
  String? extractDirectory(String? fileUrl, String html);
}

class DefaultHtmlImageExtractor extends HtmlImageExtractor {
  DefaultHtmlImageExtractor({
    this.hashRegexPattern = r'/([a-f0-9]{32,40})\.[^/]*$',
    this.directoryRegexPattern = r'/images/(\d+)/',
    this.jsHashRegexPattern = r"'img':\s*'([^']+)'",
    this.jsDirRegexPattern = r"'dir':\s*'?(\d+)'?",
    this.sampleHostTransform,
  });

  final String hashRegexPattern;
  final String directoryRegexPattern;
  final String jsHashRegexPattern;
  final String jsDirRegexPattern;
  final String? Function(String url)? sampleHostTransform;

  @override
  String? extractOriginalImageUrl(Document document) {
    final allLinks = document.querySelectorAll('a[href]');
    for (final link in allLinks) {
      if (link.text.trim() == 'Original image') {
        return ensureValidUrl(link.attributes['href']);
      }
    }

    // Fallback: try the image element src
    final imageElement = document.querySelector('#image');
    return ensureValidUrl(imageElement?.attributes['src']);
  }

  @override
  String? extractSampleImageUrl(Document document) {
    final imageElement = document.querySelector('#image');
    final url = imageElement?.attributes['src'];

    if (url != null && sampleHostTransform != null) {
      return ensureValidUrl(sampleHostTransform!(url));
    }

    return ensureValidUrl(url);
  }

  @override
  String? extractPreviewImageUrl(Document document) {
    final services = ['saucenao.com', 'iqdb.org'];

    for (final service in services) {
      final link = document.querySelector('a[href*="$service"]');
      if (link != null) {
        final extractedUrl = extractUrlFromService(link);
        if (extractedUrl != null) {
          return ensureValidUrl(extractedUrl);
        }
      }
    }

    return null;
  }

  @override
  String? extractHash(String? fileUrl, String html) {
    final hash = switch (fileUrl) {
      null => null,
      final url => RegExp(hashRegexPattern).firstMatch(url)?.group(1),
    };

    // Fallback: try extracting from JavaScript image object
    return switch (hash) {
      null => switch (RegExp(jsHashRegexPattern).firstMatch(html)?.group(1)) {
        null => null,
        final imgFilename => RegExp(
          r'([a-f0-9]{32,40})\.',
        ).firstMatch(imgFilename)?.group(1),
      },
      final h => h,
    };
  }

  @override
  String? extractDirectory(String? fileUrl, String html) {
    final directory = switch (fileUrl) {
      null => null,
      final url => RegExp(directoryRegexPattern).firstMatch(url)?.group(1),
    };

    // Fallback: try extracting from JavaScript image object
    return switch (directory) {
      null => RegExp(jsDirRegexPattern).firstMatch(html)?.group(1),
      final dir => dir,
    };
  }

  static String? extractUrlFromService(Element link) {
    final href = link.attributes['href'] ?? '';
    final urlMatch = RegExp(r'url=([^&]+)').firstMatch(href);
    if (urlMatch != null) {
      final encodedUrl = urlMatch.group(1) ?? '';
      return Uri.decodeComponent(encodedUrl);
    }
    return null;
  }
}

PostV2Dto? parseHtmlPost(
  Response response,
  Map<String, dynamic> context, {
  required HtmlImageExtractor imageExtractor,
  required String Function(Document document) tagExtractor,
}) {
  final html = response.data as String;
  log('Parsing HTML post: $html');
  final baseUrl = context['baseUrl'] as String? ?? '';
  final document = parse(html);

  final postDetails = FavoriteHtmlPostDetailsData.fromDocument(
    document,
    html,
    context,
  );

  final imageUrls = HtmlImageUrls.fromDocument(
    document,
    baseUrl,
    html,
    extractor: imageExtractor,
  );
  if (imageUrls.fileUrl == null) return null;

  final imageElement = document.querySelector('#image');
  final width = int.tryParse(imageElement?.attributes['width'] ?? '');
  final height = int.tryParse(imageElement?.attributes['height'] ?? '');

  final tags = tagExtractor(document);

  return PostV2Dto(
    id: postDetails.id,
    fileUrl: imageUrls.fileUrl,
    sampleUrl: imageUrls.sampleUrl,
    previewUrl: imageUrls.previewUrl,
    directory: imageUrls.directory,
    hash: imageUrls.hash,
    width: width,
    height: height,
    tags: tags,
    score: postDetails.score,
    rating: postDetails.rating,
    source: postDetails.source,
    owner: postDetails.owner,
  );
}

GelbooruV2Posts parseDefaultFavoritePostsHtml(
  Response response,
  Map<String, dynamic> context,
) => parseFavoritePostsHtml(
  response,
  context,
  dataExtractor: PostsDataExtractor(
    regex: RegExp(
      r"posts\[(\d+)\]\s*=\s*\{([^}]+)\}",
      multiLine: true,
    ),
    bodyParser: (id, body) {
      // Extract tags - handles both "tags" and 'tags' keys with both quote styles
      final tagsMatch = RegExp(
        r'''(?:'tags'|tags):\s*(?:"([^"]+)"|'([^']+)')''',
      ).firstMatch(body);
      final tagsString = tagsMatch?.group(1) ?? tagsMatch?.group(2) ?? '';

      // Decode and split tags
      final decodedTags = tagsString.isNotEmpty
          ? Uri.decodeComponent(
              tagsString,
            ).split(' ').where((tag) => tag.isNotEmpty).toList()
          : <String>[];

      // Extract rating - handles both quote styles
      final ratingMatch = RegExp(
        r"(?:'rating'|rating):\s*'([^']+)'",
      ).firstMatch(body);
      final rating = ratingMatch?.group(1) ?? '';

      // Extract score - handles both quoted strings and unquoted numbers
      final scoreMatch = RegExp(
        r"(?:'score'|score):\s*'?(\d+)'?",
      ).firstMatch(body);
      final score = int.tryParse(scoreMatch?.group(1) ?? '0') ?? 0;

      // Extract user - handles both quote styles
      final userMatch = RegExp(
        r'''(?:'user'|user):\s*(?:"([^"]+)"|'([^']+)')''',
      ).firstMatch(body);
      final user = userMatch?.group(1) ?? userMatch?.group(2) ?? '';

      return ExtractedPostData(
        id: id,
        tags: decodedTags,
        rating: convertRating(rating),
        score: score,
        user: user,
      );
    },
  ),
);

PostV2Dto? parseDefaultPostHtml(
  Response response,
  Map<String, dynamic> context, {
  HtmlImageExtractor? imageExtractor,
}) => parseHtmlPost(
  response,
  context,
  imageExtractor: imageExtractor ?? DefaultHtmlImageExtractor(),
  tagExtractor: _extractUniversalTags,
);

String _extractUniversalTags(Document document) {
  final tagElements = document.querySelectorAll(
    '#tag-sidebar .tag-type-copyright a[href*="tags="], '
    '#tag-sidebar .tag-type-character a[href*="tags="], '
    '#tag-sidebar .tag-type-general a[href*="tags="], '
    '#tag-sidebar .tag-type-artist a[href*="tags="], '
    '#tag-sidebar .tag-type-meta a[href*="tags="], '
    '#tag-sidebar .tag-type-metadata a[href*="tags="]',
  );

  final tags = tagElements
      .map((e) => e.text.trim())
      // Clean up multi-line tags and normalize spaces
      .map((tag) => tag.replaceAll(RegExp(r'\s+'), ' ').trim())
      // Convert spaces to underscores for tag format
      .map((tag) => tag.replaceAll(' ', '_'))
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .join(' ');

  return tags;
}
