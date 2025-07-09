// Package imports:
import 'dart:convert';
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kYandereUrl = 'https://yande.re';
const _kKonachanUrl = 'https://konachan.com';

class MoebooruClient {
  MoebooruClient({
    String? baseUrl,
    Map<String, String>? headers,
    this.login,
    this.passwordHashed,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? '',
               headers: headers ?? {},
             ),
           );

  factory MoebooruClient.yandere({
    Dio? dio,
    String? login,
    String? passwordHashed,
  }) => MoebooruClient(
    baseUrl: _kYandereUrl,
    dio: dio,
    login: login,
    passwordHashed: passwordHashed,
  );

  factory MoebooruClient.konachan({
    Dio? dio,
    String? login,
    String? passwordHashed,
  }) => MoebooruClient(
    baseUrl: _kKonachanUrl,
    dio: dio,
    login: login,
    passwordHashed: passwordHashed,
  );

  factory MoebooruClient.custom({
    required String baseUrl,
    Dio? dio,
    String? login,
    String? apiKey,
  }) => MoebooruClient(
    baseUrl: baseUrl,
    dio: dio,
    login: login,
    passwordHashed: apiKey,
  );

  final Dio _dio;
  final String? login;
  final String? passwordHashed;

  Future<List<PostDto>> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) async {
    final response = await _dio.get(
      '/post.json',
      queryParameters: {
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<TagSummaryDto> getTagSummary() async {
    final response = await _dio.get(
      '/tag/summary.json',
      queryParameters: {
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return TagSummaryDto.fromJson(response.data);
  }

  Future<List<PostDto>> getPopularPostsRecent({
    TimePeriod period = TimePeriod.day,
  }) async {
    final response = await _dio.get(
      '/post/popular_recent.json',
      queryParameters: {
        'period': switch (period) {
          TimePeriod.day => '1d',
          TimePeriod.week => '1w',
          TimePeriod.month => '1m',
          TimePeriod.year => '1y',
        },
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<PostDto>> getPopularPostsByDay({
    DateTime? date,
  }) async {
    date ??= DateTime.now();

    final response = await _dio.get(
      '/post/popular_by_day.json',
      queryParameters: {
        'day': date.day,
        'month': date.month,
        'year': date.year,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<PostDto>> getPopularPostsByWeek({
    DateTime? date,
  }) async {
    date ??= DateTime.now();

    final response = await _dio.get(
      '/post/popular_by_week.json',
      queryParameters: {
        'day': date.day,
        'month': date.month,
        'year': date.year,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<PostDto>> getPopularPostsByMonth({
    DateTime? date,
  }) async {
    date ??= DateTime.now();

    final response = await _dio.get(
      '/post/popular_by_month.json',
      queryParameters: {
        'month': date.month,
        'year': date.year,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<List<CommentDto>> getComments({
    required int postId,
  }) async {
    final response = await _dio.get(
      '/comment.json',
      queryParameters: {
        'post_id': postId,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );

    return (response.data as List)
        .map((item) => CommentDto.fromJson(item))
        .toList();
  }

  Future<void> votePost({
    required int postId,
    required int score,
  }) async {
    await _dio.post(
      '/post/vote.json',
      queryParameters: {
        'id': postId,
        'score': score,
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        },
      },
    );
  }

  Future<void> unfavoritePost({
    required int postId,
  }) async {
    await votePost(postId: postId, score: 0);
  }

  Future<void> favoritePost({
    required int postId,
  }) async {
    await votePost(postId: postId, score: 3);
  }

  Future<Set<String>?> getFavoriteUsers({
    required int postId,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      '/favorite/list_users.json',
      queryParameters: {
        'id': postId,
      },
      cancelToken: cancelToken,
    );

    final userString = response.data['favorited_users'] as String?;
    if (userString == null) return {};

    return userString.split(',').toSet();
  }

  Future<PostDto?> getPost(int id) async {
    try {
      final response = await _dio.get(
        '/post/show/$id',
      );

      final html = response.data as String;

      // First try the JavaScript approach
      final jsRegex = RegExp(r'Post\.register_resp\((.*?)\);');
      final jsMatch = jsRegex.firstMatch(html);

      if (jsMatch != null && jsMatch.group(1) != null) {
        try {
          final data = jsonDecode(jsMatch.group(1)!) as Map<String, dynamic>;
          final posts = data['posts'] as List;

          if (posts.isNotEmpty) {
            return PostDto.fromJson(posts.first as Map<String, dynamic>);
          }
        } catch (_) {
          // JSON parsing failed, continue to HTML parsing
        }
      }

      // Fallback to HTML parsing
      return _parsePostFromHtml(html, id);
    } catch (e) {
      return null;
    }
  }

  /// Parse post data from HTML content when JavaScript data isn't available
  PostDto? _parsePostFromHtml(String html, int id) {
    // Extract tags
    final tagsRegex = RegExp(r'name="post\[old_tags\]"[^>]*value="([^"]+)"');
    final tagMatch = tagsRegex.firstMatch(html);
    final tags = tagMatch?.group(1) ?? '';

    // Extract source
    final sourceRegex = RegExp(r'<li>Source: (.*?)</li>');
    final sourceMatch = sourceRegex.firstMatch(html);
    final source = sourceMatch?.group(1);

    // Extract rating
    final ratingRegex = RegExp(r'<li>Rating: (.*?) <span');
    final ratingMatch = ratingRegex.firstMatch(html);
    final rating = ratingMatch?.group(1)?.toLowerCase();

    // Extract dimensions
    final sizeRegex = RegExp(r'<li>Size: (\d+)x(\d+)</li>');
    final sizeMatch = sizeRegex.firstMatch(html);
    final width = sizeMatch != null
        ? int.tryParse(sizeMatch.group(1) ?? '')
        : null;
    final height = sizeMatch != null
        ? int.tryParse(sizeMatch.group(2) ?? '')
        : null;

    // Extract MD5 - try to find it in file URLs
    String? md5;
    final md5Regex = RegExp(r'/data/([a-f0-9]{32})\.');
    final md5Match = md5Regex.firstMatch(html);
    if (md5Match != null) {
      md5 = md5Match.group(1);
    }

    // Extract file URLs
    String? fileUrl;
    final videoRegex = RegExp(r'<source src="([^"]+)" type="video/');
    final videoMatch = videoRegex.firstMatch(html);
    if (videoMatch != null) {
      fileUrl = videoMatch.group(1);
    } else {
      final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"[^>]+id="image"');
      final imgMatch = imgRegex.firstMatch(html);
      fileUrl = imgMatch?.group(1);
    }

    // Extract sample/preview URL from meta tags
    String? previewUrl;
    final previewRegex = RegExp(r'<meta property="og:image" content="([^"]+)"');
    final previewMatch = previewRegex.firstMatch(html);
    previewUrl = previewMatch?.group(1);

    // Extract score
    final scoreRegex = RegExp(r'<span id="post-score-\d+">(\d+)</span>');
    final scoreMatch = scoreRegex.firstMatch(html);
    final score = scoreMatch != null
        ? int.tryParse(scoreMatch.group(1) ?? '')
        : null;

    // Extract file extension
    String? fileExt;
    if (fileUrl != null) {
      final extRegex = RegExp(r'\.([a-zA-Z0-9]+)(?:\?|$)');
      final extMatch = extRegex.firstMatch(fileUrl);
      fileExt = extMatch?.group(1);
    }

    // Extract created timestamp from title attribute in posted date
    final createdAtRegex = RegExp(r'<a title="([^"]+)" href="/post\?tags=date');
    final createdAtMatch = createdAtRegex.firstMatch(html);
    int? createdAt;
    if (createdAtMatch != null) {
      try {
        final dateStr = createdAtMatch.group(1);
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          createdAt = date.millisecondsSinceEpoch ~/ 1000;
        }
      } catch (_) {}
    }

    // Check if this post is deleted
    final isDeleted = html.contains(
      '<div class="status-notice">\n    This post was deleted.',
    );

    return PostDto(
      id: id,
      tags: tags,
      source: source,
      rating: rating,
      width: width,
      height: height,
      md5: md5,
      fileUrl: fileUrl,
      previewUrl: previewUrl,
      score: score,
      fileExt: fileExt,
      createdAt: createdAt,
      status: isDeleted ? 'deleted' : 'active',
    );
  }
}
