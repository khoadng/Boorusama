import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../types/types.dart';
import 'gel_parsers.dart';

List<TagDto> parseRbTagsHtml(Response response, Map<String, dynamic> context) {
  final html = response.data as String;
  final document = parse(html);
  final tagLink = document.getElementById('tagLink');

  if (tagLink == null) return [];

  final tags = <TagDto>[];

  // Extract different tag types
  final metaTags = tagLink.querySelectorAll('a.metadata');
  final generalTags = tagLink.querySelectorAll('a.tag-type-general');
  final modelTags = tagLink.querySelectorAll('a.model');
  final artistTags = tagLink.querySelectorAll('a.tag-type-artist');
  final copyrightTags = tagLink.querySelectorAll('a.tag-type-copyright');
  final characterTags = tagLink.querySelectorAll('a.tag-type-character');

  // Parse each tag type
  tags.addAll(_parseRbTagElements(artistTags, 1));
  tags.addAll(_parseRbTagElements(copyrightTags, 3));
  tags.addAll(_parseRbTagElements(characterTags, 4));
  tags.addAll(_parseRbTagElements(generalTags, 0));
  tags.addAll(_parseRbTagElements(metaTags, 5));
  tags.addAll(_parseRbTagElements(modelTags, 1)); // Treat models as artists

  return tags;
}

List<TagDto> _parseRbTagElements(List<Element> elements, int type) {
  return elements.map((element) {
    final name = element.text.trim().replaceAll(' ', '_');
    final href = element.attributes['href'] ?? '';

    // Try to extract count from URL if available (usually not present in post view)
    final countMatch = RegExp(r'count=(\d+)').firstMatch(href);
    final count = countMatch != null
        ? int.tryParse(countMatch.group(1) ?? '')
        : null;

    return TagDto(
      id: null, // Not available in HTML
      name: name,
      count: count,
      type: type,
      ambiguous: null, // Not available
    );
  }).toList();
}

PostV2Dto? parseRbPostHtml(
  Response response,
  Map<String, dynamic> context,
) {
  final html = response.data as String;
  final baseUrl = context['baseUrl'] as String? ?? '';
  final document = parse(html);

  final postId = _extractPostId(document);
  if (postId == null) return null;

  // Try to get file URL from video or image
  String? fileUrl;

  // Check for video first
  final videoSource = document.querySelector('#gelcomVideoPlayer source');
  if (videoSource != null) {
    fileUrl = videoSource.attributes['src'];
  } else {
    // Check for image
    final imageElement = document.querySelector('#image');
    fileUrl = imageElement?.attributes['src'];
  }

  if (fileUrl == null) return null;

  // Extract hash and directory
  final hashMatch = RegExp(r'/([a-f0-9]{32})\.').firstMatch(fileUrl);
  final hash = hashMatch?.group(1);

  final directoryMatch = RegExp(
    r'/images/([a-f0-9]{2})/([a-f0-9]{2})/',
  ).firstMatch(fileUrl);
  final directory = directoryMatch != null
      ? '${directoryMatch.group(1)}/${directoryMatch.group(2)}'
      : null;

  // Extract other data
  final scoreElement = document.querySelector('#psc$postId');
  final score = int.tryParse(scoreElement?.text ?? '');

  final sourceInput = document.querySelector('input[name="source"]');
  final source = sourceInput?.attributes['value'] ?? '';

  final tags = _extractTags(document);

  // Build preview URL
  final previewUrl = hash != null && directory != null
      ? '$baseUrl/thumbnails/$directory/thumbnail_$hash.jpg'
      : '';

  return PostV2Dto(
    id: postId,
    fileUrl: fileUrl,
    sampleUrl: fileUrl,
    previewUrl: previewUrl,
    directory: directory,
    hash: hash,
    tags: tags,
    score: score,
    source: source,
  );
}

int? _extractPostId(Document document) {
  // Try multiple methods to extract post ID
  final hiddenInput = document.querySelector('input[name="id"]');
  if (hiddenInput != null) {
    return int.tryParse(hiddenInput.attributes['value'] ?? '');
  }

  // Fallback: extract from script or other elements
  final scriptText = document.querySelector('script')?.text ?? '';
  final match = RegExp(r"post_vote\('(\d+)'").firstMatch(scriptText);
  return match != null ? int.tryParse(match.group(1) ?? '') : null;
}

String _extractTags(Document document) {
  final tagElements = document.querySelectorAll('a[class*="tag-"], a.metadata');
  final tags = tagElements
      .map((e) => e.text.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet() // Remove duplicates
      .join(' ');

  return tags;
}

GelbooruV2Posts parseRbPostsHtml(
  Response response,
  Map<String, dynamic> context,
) {
  final document = parse(response.data);
  final data = document.getElementsByClassName('thumb');

  final posts = data.map((element) {
    final linkElement = element.firstChild!;
    final imageElement = linkElement.firstChild!;

    final id = int.tryParse(linkElement.attributes['id']!.substring(1));
    var thumbUrl = imageElement.attributes['src']!;

    // Fix protocol if needed
    if (!thumbUrl.startsWith('https') && thumbUrl.startsWith('//')) {
      thumbUrl = 'https:$thumbUrl';
    }

    final fileUrl = thumbUrl
        .replaceFirst('thumbs', 'img')
        .replaceFirst('thumbnails', 'images')
        .replaceFirst('thumbnail_', '');

    final tags = imageElement.attributes['title'];
    final md5 = thumbUrl.substring(
      thumbUrl.lastIndexOf('_') + 1,
      thumbUrl.lastIndexOf('.'),
    );

    // Parse tags for score and rating
    final tagList = tags?.split(' ') ?? <String>[];
    int? score;
    String? rating;

    for (final tag in tagList) {
      if (tag.startsWith('score:')) {
        score = int.tryParse(tag.replaceAll('score:', ''));
      } else if (tag.startsWith('rating:')) {
        rating = tag.replaceAll('rating:', '');
      }
    }

    final cleanTags = tagList
        .where((e) => e.isNotEmpty)
        .where((e) => !e.startsWith('rating:'))
        .where((e) => !e.startsWith('score:'))
        .join(' ');

    return PostV2Dto(
      id: id,
      fileUrl: fileUrl,
      sampleUrl: fileUrl,
      previewUrl: thumbUrl,
      tags: cleanTags,
      hash: md5,
      rating: rating,
      score: score,
    );
  }).toList();

  return (posts: posts, count: null);
}
