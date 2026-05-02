// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _basePath = '/api/v3';

class AnimePicturesClient {
  AnimePicturesClient({
    Dio? dio,
    required String baseUrl,
    this.cookie,
  }) {
    _dio = dio ?? Dio();

    var url = baseUrl;
    _siteUrl = _normalizeUrl(url.replaceFirst('https://api.', 'https://'));

    if (url.startsWith('https://anime-pictures')) {
      url = url.replaceFirst('https://', 'https://api.');
    }

    url = _normalizeUrl(url);

    final headers = Map<String, dynamic>.from(_dio.options.headers);
    headers['Referer'] ??= _siteUrl;
    headers['cookie'] = CookieUtils.mergeCookieHeaders(
      headers['cookie']?.toString() ?? '',
      CookieUtils.mergeCookieHeaders('sitelang=en', cookie ?? ''),
    );

    _dio.options = _dio.options.copyWith(
      baseUrl: url,
      headers: headers,
    );
  }

  late final Dio _dio;
  late final String _siteUrl;
  final String? cookie;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
    int? starsBy,
    PostOrder? orderBy,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;

    final response = await _dio.get(
      '$_basePath/posts',
      queryParameters: {
        'stars_by': ?starsBy,
        if (!isEmpty) 'search_tag': tags!.join(' '),
        'page': (page ?? 1) - 1,
        'posts_per_page': ?limit,
        if (orderBy != null)
          'order_by': switch (orderBy) {
            PostOrder.starsDate => 'stars_date',
          },
      },
    );

    final results = response.data['posts'] as List;

    return results
        .map(
          (item) => PostDto.fromJson(
            item,
            _dio.options.baseUrl,
          ),
        )
        .toList();
  }

  Future<PostDetailsDto> getPostDetails({
    required int id,
  }) async {
    final response = await _dio.get(
      '$_basePath/posts/$id',
      queryParameters: {
        'extra': 'similar_pictures',
      },
    );

    return PostDetailsDto.fromJson(
      response.data,
      _dio.options.baseUrl,
    );
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '$_basePath/tags:autocomplete',
      queryParameters: {
        'tag': query,
      },
    );

    final results = response.data['tags'] as List;

    return results.map((item) => AutocompleteDto.fromJson(item)).toList();
  }

  final _downloadUrlCache = <int, AnimePicturesDownloadUrlData>{};

  Future<AnimePicturesDownloadUrlData?> getDownloadUrl(int postId) async {
    if (_downloadUrlCache.containsKey(postId)) {
      return _downloadUrlCache[postId];
    }

    final postDetails = await getPostDetails(id: postId);

    final fileUrl = postDetails.fileUrl;

    if (fileUrl == null) {
      return null;
    }

    final url = _joinUrl(
      _dio.options.baseUrl,
      'pictures/download_image/$fileUrl',
    );

    final res = await _dio.get(
      url,
      options: Options(
        followRedirects: false,
        validateStatus: (status) =>
            status != null && status >= 300 && status < 400,
        headers: {
          'Referer': _siteUrl,
          'cookie': CookieUtils.mergeCookieHeaders(
            'sitelang=en',
            cookie ?? '',
          ),
        },
      ),
    );

    final location = res.headers['location']?.firstOrNull;
    final cookieValue = res.headers['set-cookie']?.firstOrNull;
    final redirectCookie = cookieValue != null
        ? CookieUtils.fromSetCookieValue(cookieValue)
        : null;

    if (location == null) {
      return null;
    }

    final cookieString = CookieUtils.mergeCookieHeaders(
      CookieUtils.mergeCookieHeaders('sitelang=en', cookie ?? ''),
      redirectCookie != null
          ? '${redirectCookie.name}=${redirectCookie.value}'
          : '',
    );

    final data = (
      url: location,
      cookie: cookieString,
    );

    _downloadUrlCache[postId] = data;

    return data;
  }

  Future<List<PostDto>> getTopPosts({
    TopLength? length,
    bool? erotic,
  }) async {
    final l = length ?? TopLength.week;

    final resp = await _dio.get(
      '$_basePath/top',
      queryParameters: {
        'length': l.name,
        'erotic': erotic == true ? 1 : '',
      },
    );

    final results = resp.data['top'] as List;

    return results
        .map(
          (item) => PostDto.fromJson(
            item,
            _dio.options.baseUrl,
          ),
        )
        .toList();
  }

  Future<UserDto> getProfile() async {
    final response = await _dio.get(
      '$_basePath/profile',
    );

    final result = response.data['user'];

    return UserDto.fromJson(result);
  }
}

typedef AnimePicturesDownloadUrlData = ({String url, String cookie});

String _normalizeUrl(String url) => url.endsWith('/') ? url : '$url/';

String _joinUrl(String baseUrl, String path) =>
    '${_normalizeUrl(baseUrl)}${path.startsWith('/') ? path.substring(1) : path}';
