// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

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
        headers: {
          HttpHeaders.cookieHeader: 'user_id=$userId; pass_hash=$passHash',
        },
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
        headers: {
          HttpHeaders.cookieHeader: 'user_id=$userId; pass_hash=$passHash',
        },
      ),
    );
  }
}
