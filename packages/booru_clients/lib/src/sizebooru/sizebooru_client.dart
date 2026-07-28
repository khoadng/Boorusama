// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

// Project imports:
import 'types/types.dart';

const _kSizebooruDefaultUrl = 'https://sizebooru.com';
const kSizebooruDefaultPageSize = 50;
const kSizebooruMaxPageSize = 100;

class SizebooruClient {
  SizebooruClient({
    Dio? dio,
    String? baseUrl,
    this.logger,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? _kSizebooruDefaultUrl,
             ),
           );

  final Dio _dio;
  final void Function(String message)? logger;

  Future<Map<String, int>>? _allTagsFuture;

  Future<List<SizebooruPostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final pageSize = _clampPageSize(limit) ?? kSizebooruDefaultPageSize;
    final pageNo = (page ?? 1).clamp(1, 1 << 30);

    final query = (tags ?? const <String>[])
        .where((e) => e.trim().isNotEmpty)
        .join(' ');

    // `/Search` paginates only when `q` is set; for empty queries the listing
    // lives at `/Home`, which honors `pageNo`/`pageSize` for infinite scroll.
    final path = query.isEmpty ? '/Home' : '/Search';

    try {
      final response = await _dio.get<String>(
        path,
        queryParameters: {
          if (query.isNotEmpty) 'q': query,
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data;
      if (body == null || body.isEmpty) return [];

      return _parseListing(body);
    } catch (e, stackTrace) {
      logger?.call('Sizebooru getPosts error: $e');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  Future<SizebooruPostDto?> getPost(int id) async {
    try {
      final response = await _dio.get<String>(
        '/Details/$id',
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data;
      if (body == null || body.isEmpty) return null;

      return _parseDetails(id, body);
    } catch (e, stackTrace) {
      logger?.call('Sizebooru getPost error: $e');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  /// Extracts the tag list for a given post by scraping the details page.
  Future<List<String>> getTagsFromPostId(int id) async {
    final post = await getPost(id);
    return post?.tags ?? const [];
  }

  /// Sizebooru ships its full `{tag: count}` dictionary as a single JSON blob
  /// at `/Tags/Json` and the website filters client-side. We mirror that:
  /// fetch once, cache in memory, then prefix-filter and sort by count.
  Future<List<SizebooruAutocompleteDto>> getAutocomplete({
    required String query,
    int limit = 15,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    try {
      final all = await _getAllTags();
      if (all.isEmpty) return const [];

      final entries =
          all.entries.where((e) => e.key.toLowerCase().startsWith(q)).toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      return entries
          .take(limit)
          .map(
            (e) => SizebooruAutocompleteDto(
              value: e.key,
              label: e.key,
              postCount: e.value,
            ),
          )
          .toList();
    } catch (e) {
      logger?.call('Sizebooru autocomplete error: $e');
      return const [];
    }
  }

  Future<Map<String, int>> _getAllTags() {
    return _allTagsFuture ??= _fetchAllTags();
  }

  Future<Map<String, int>> _fetchAllTags() async {
    try {
      final response = await _dio.get<String>(
        '/Tags/Json',
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data;
      if (body == null || body.isEmpty) return const {};

      final decoded = jsonDecode(body);
      if (decoded is! Map) return const {};

      final out = <String, int>{};
      decoded.forEach((key, value) {
        if (key is String && value is num) {
          out[key] = value.toInt();
        }
      });
      return out;
    } catch (e) {
      logger?.call('Sizebooru tag dictionary fetch error: $e');
      // Drop the cached failed future so the next caller can retry.
      _allTagsFuture = null;
      return const {};
    }
  }

  String thumbnailUrl(int id) => '${_dio.options.baseUrl}/Thumb?id=$id';
  String fullImageUrl(int id) => '${_dio.options.baseUrl}/Picture/$id';

  List<SizebooruPostDto> _parseListing(String html) {
    final document = parse(html);
    // Each result is <a href="/Details/<id>?..."><div class="thumbnail-container"><img src="/Thumb?id=<id>" alt="<tags>" /></div></a>
    final anchors = document.querySelectorAll('a[href^="/Details/"]');

    final seen = <int>{};
    final out = <SizebooruPostDto>[];
    for (final a in anchors) {
      final href = a.attributes['href'] ?? '';
      final id = _extractId(href);
      if (id == null || !seen.add(id)) continue;

      final img = a.querySelector('img');
      if (img == null) continue;

      final src = img.attributes['src'];
      final alt = img.attributes['alt'] ?? '';
      final tags = _splitTags(alt);

      out.add(
        SizebooruPostDto(
          id: id,
          tags: tags,
          thumbnailUrl: src != null ? _absolute(src) : null,
          fileUrl: _absolute('/Picture/$id'),
        ),
      );
    }
    return out;
  }

  SizebooruPostDto _parseDetails(int id, String html) {
    final document = parse(html);

    final mainImg = _findDetailsMainImage(document);
    final fileSrc = mainImg?.attributes['src'];
    final filename = mainImg?.attributes['alt'];

    // Tag list — anchors with href="/Search/<tag>" inside the details page.
    final tagAnchors = document.querySelectorAll('a[href^="/Search/"]');
    final tags = <String>{};
    for (final a in tagAnchors) {
      final href = a.attributes['href'] ?? '';
      final tag = Uri.decodeComponent(
        href.replaceFirst('/Search/', '').split('?').first,
      );
      if (tag.isEmpty) continue;
      // Tag links sometimes appear in the sidebar's "Popular Tags" too —
      // we still want them all so we just dedupe by value.
      tags.add(tag);
    }

    // Pull a few details fields by label from the Details card.
    String? artist;
    String? uploader;
    String? source;
    DateTime? createdAt;

    final detailsCard = document
        .querySelectorAll('.card')
        .where((el) => el.text.trimLeft().startsWith('Details'))
        .firstOrNull;
    if (detailsCard != null) {
      final spans = detailsCard.querySelectorAll('span');
      for (final span in spans) {
        final text = span.text.trim();
        if (text.startsWith('Artist:')) {
          artist = text.replaceFirst('Artist:', '').trim();
        } else if (text.startsWith('Posted By:')) {
          final a = span.querySelector('a');
          uploader =
              a?.text.trim() ?? text.replaceFirst('Posted By:', '').trim();
        } else if (text.startsWith('Source Link:')) {
          final a = span.querySelector('a');
          source = a?.attributes['href'];
        } else if (text.startsWith('Posted Date:')) {
          createdAt = _tryParseUsDate(
            text.replaceFirst('Posted Date:', '').trim(),
          );
        }
      }
    }

    return SizebooruPostDto(
      id: id,
      tags: tags.toList(),
      thumbnailUrl: _absolute('/Thumb?id=$id'),
      fileUrl: fileSrc != null ? _absolute(fileSrc) : _absolute('/Picture/$id'),
      filename: filename,
      artist: artist,
      uploader: uploader,
      source: source,
      createdAt: createdAt,
    );
  }

  Element? _findDetailsMainImage(Document document) {
    // The full image lives inside a <center> block as <img src="/Picture/NN">
    for (final img in document.querySelectorAll('img')) {
      final src = img.attributes['src'] ?? '';
      if (src.startsWith('/Picture/') || src.contains('/Picture/')) {
        return img;
      }
    }
    return null;
  }

  int? _extractId(String href) {
    // /Details/286885?source=search&q=giantess
    final path = href.split('?').first;
    final match = RegExp(r'/Details/(\d+)').firstMatch(path);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  List<String> _splitTags(String alt) {
    return alt
        .split(RegExp(r'\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _absolute(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = _dio.options.baseUrl.replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return '$base$p';
  }

  DateTime? _tryParseUsDate(String input) {
    // Format on the page: 04/29/2026
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(input);
    if (m == null) return null;
    final month = int.tryParse(m.group(1) ?? '');
    final day = int.tryParse(m.group(2) ?? '');
    final year = int.tryParse(m.group(3) ?? '');
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  int? _clampPageSize(int? limit) {
    if (limit == null) return null;
    if (limit < 1) return 1;
    if (limit > kSizebooruMaxPageSize) return kSizebooruMaxPageSize;
    return limit;
  }
}
