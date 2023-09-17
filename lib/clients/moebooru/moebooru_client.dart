// Package imports:
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
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? '',
              headers: headers ?? {},
            ));

  final Dio _dio;
  final String? login;
  final String? passwordHashed;

  factory MoebooruClient.yandere({
    Dio? dio,
    String? login,
    String? passwordHashed,
  }) =>
      MoebooruClient(
        baseUrl: _kYandereUrl,
        dio: dio,
        login: login,
        passwordHashed: passwordHashed,
      );

  factory MoebooruClient.konachan({
    Dio? dio,
    String? login,
    String? passwordHashed,
  }) =>
      MoebooruClient(
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
  }) =>
      MoebooruClient(
        baseUrl: baseUrl,
        dio: dio,
        login: login,
        passwordHashed: apiKey,
      );

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
        }
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
        }
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
          TimePeriod.year => '1y'
        },
        if (login != null && passwordHashed != null) ...{
          'login': login,
          'password_hash': passwordHashed,
        }
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
        }
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
        }
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
        }
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
        }
      },
    );

    return (response.data as List)
        .map((item) => CommentDto.fromJson(item))
        .toList();
  }
}
