import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:intl/intl.dart';

class PostDto {
  PostDto({
    this.id,
    this.submittedBy,
    this.submittedOn,
    this.filename,
    this.imageUrl,
    this.thumbnailUrl,
    this.fileSize,
    this.width,
    this.height,
    this.megapixels,
    this.tags,
    this.source,
    this.characters,
    this.artist,
  });

  final int? id;
  final String? submittedBy;
  final DateTime? submittedOn;
  final String? filename;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? fileSize;
  final int? width;
  final int? height;
  final double? megapixels;
  final List<String>? tags;
  final List<String>? source;
  final List<String>? characters;
  final List<String>? artist;

  factory PostDto.fromHtml(Element postElement, String baseUrl) {
    // Parse ID
    final idString = postElement.id.replaceFirst('i', '');
    final id = int.tryParse(idString);

    // Parse metadata
    final metaDiv = postElement.querySelector('div.meta');
    final dl = metaDiv?.querySelector('dl');
    final data = <String, String>{};

    dl?.querySelectorAll('dt').forEach((dt) {
      final label = dt.text.trim().replaceAll(':', '');
      final dd = dt.nextElementSibling;
      if (dd != null) {
        data[label] = dd.text.trim();
      }
    });

    // Parse date
    final dateString = data['Submitted On'];
    final submittedOn = dateString != null
        ? _parseDateString(dateString)
        : null;

    // Parse dimensions
    final dimensions = data['Dimensions'] ?? '';
    final (w, h, mp) = _parseDimensions(dimensions);

    // Parse other fields
    final tags = _parseQuickTag(metaDiv, 'quicktag1_');
    final source = _parseQuickTag(metaDiv, 'quicktag2_');
    final artist = _parseQuickTag(metaDiv, 'quicktag3_');
    final characters = _parseQuickTag(metaDiv, 'quicktag4_');

    // Parse image URLs
    final thumbLink = postElement.querySelector('a.thumb_image');
    final imageHref = thumbLink?.attributes['href'];
    final filename = imageHref?.split('/').lastOrNull;

    final thumbnailSrc = thumbLink?.querySelector('img')?.attributes['src'];
    final thumbnailUrl = thumbnailSrc != null
        ? Uri.parse(baseUrl).resolve(thumbnailSrc).toString()
        : null;

    final imageUrl = imageHref != null
        ? Uri.parse(baseUrl).resolve(imageHref).toString()
        : null;

    return PostDto(
      id: id,
      submittedBy: data['Submitted By'],
      submittedOn: submittedOn,
      filename: filename,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      fileSize: data['File size'],
      width: w,
      height: h,
      megapixels: mp,
      tags: tags,
      source: source,
      characters: characters,
      artist: artist,
    );
  }

  @override
  String toString() {
    return '''
Post ID: ${id ?? 'N/A'}
Submitted By: ${submittedBy ?? 'Unknown'}
Submitted On: ${submittedOn?.toIso8601String() ?? 'Unknown date'}
Filename: ${filename ?? 'Unknown'}
File size: ${fileSize ?? 'Unknown'}
Width: ${width ?? 'Unknown'}
Height: ${height ?? 'Unknown'}
Megapixels: ${megapixels ?? 'Unknown'}
Tags: ${tags?.join(', ') ?? 'None'}
Source: ${source?.join(', ') ?? 'Unknown'}
Characters: ${characters?.join(', ') ?? 'None'}
Artist: ${artist?.join(', ') ?? 'Unknown'}
------------------------------------''';
  }
}

List<PostDto> parsePosts(String html, String baseUrl) {
  final document = parser.parse(html);
  final postElements = document.querySelectorAll('div.image_thread');
  final posts = <PostDto>[];

  for (var postElement in postElements) {
    posts.add(PostDto.fromHtml(postElement, baseUrl));
  }

  return posts;
}

DateTime? _parseDateString(String dateString) {
  try {
    // Remove ordinal suffix (st, nd, rd, th)
    final cleaned = dateString.replaceAllMapped(
      RegExp(r'(\d+)(st|nd|rd|th)'),
      (match) => match.group(1)!,
    );

    return DateFormat('MMMM d, y h:mm a').parse(cleaned);
  } catch (e) {
    return null;
  }
}

(int?, int?, double?) _parseDimensions(String dimensions) {
  try {
    final match = RegExp(
      r'(\d+)x(\d+).*?([\d.]+)\s+MPixel',
    ).firstMatch(dimensions);
    if (match == null) return (null, null, null);

    return (
      int.tryParse(match.group(1) ?? ''),
      int.tryParse(match.group(2) ?? ''),
      double.tryParse(match.group(3) ?? ''),
    );
  } catch (e) {
    return (null, null, null);
  }
}

List<String>? _parseQuickTag(Element? metaDiv, String prefix) {
  final dd = metaDiv?.querySelector('dd[id^="$prefix"]');
  if (dd == null) return null;

  return dd.querySelectorAll('span.tag').map((span) {
    return span.text
        .trim()
        .replaceAll('"', '')
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }).toList();
}
