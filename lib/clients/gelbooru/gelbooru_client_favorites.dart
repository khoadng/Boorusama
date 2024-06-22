// Dart imports:
import 'dart:io';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

// Project imports:
import 'types/post_dto.dart';

enum GelbooruFavoriteStatus {
  unknown,
  success,
  alreadyFavorited,
  failed,
  userNotLoggedIn,
}

mixin GelbooruClientFavorites {
  Dio get dio;

  String? get userId;
  String? get passHash;

  bool get canFavorite => userId != null && passHash != null;

  Future<GelbooruFavoriteStatus> addFavorite({
    required int postId,
  }) async {
    if (userId == null || passHash == null) {
      return GelbooruFavoriteStatus.userNotLoggedIn;
    }

    final a = await dio.get(
      '/public/addfav.php',
      queryParameters: {
        'id': postId,
      },
      options: Options(
        headers: _buildHeaders(),
      ),
    );

    return switch (a.data) {
      '1' => GelbooruFavoriteStatus.alreadyFavorited,
      '2' => GelbooruFavoriteStatus.failed,
      '3' => GelbooruFavoriteStatus.success,
      _ => GelbooruFavoriteStatus.unknown,
    };
  }

  Future<void> removeFavorite({
    required int postId,
  }) async {
    if (userId == null || passHash == null) {
      throw Exception('User not logged in');
    }

    final _ = await dio.get(
      '/index.php',
      queryParameters: {
        'page': 'favorites',
        's': 'delete',
        'id': postId,
      },
      options: Options(
        validateStatus: (status) => status == 200 || status == 302,
        headers: _buildHeaders(),
      ),
    );
  }

  Map<String, dynamic> _buildHeaders() => {
        HttpHeaders.cookieHeader: 'user_id=$userId; pass_hash=$passHash',
      };

  Future<List<PostFavoriteDto>> getFavorites({
    int? page,
    int? limit,
  }) async {
    final response = await dio.get(
      '/index.php',
      queryParameters: {
        'page': 'favorites',
        's': 'view',
        if (userId != null) 'id': userId,
        if (page != null) 'pid ': page - 1,
        if (limit != null) 'limit': limit,
      },
      options: Options(
        headers: _buildHeaders(),
      ),
    );

    final data = response.data;

    // parse html
    final html = parse(data);

    // get all class "thumb" elements
    final thumbs =
        html.getElementsByClassName('thumb').map((e) => e.firstChild).toList();

    return thumbs.whereNotNull().map((e) {
      final id = int.tryParse(e.attributes['id']?.substring(1) ?? '');
      final imgSrc = e.firstChild?.attributes['src'];
      final tags = e.firstChild?.attributes['title'];

      return PostFavoriteDto(
        id: id,
        tags: tags,
        previewUrl: imgSrc,
      );
    }).toList();
  }
}
