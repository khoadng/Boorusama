// Package imports:
import 'package:dio/dio.dart';

import 'gelbooru_session.dart';

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
    final currentUserId = userId;
    final currentPassHash = passHash;
    if (currentUserId == null || currentPassHash == null) {
      return GelbooruFavoriteStatus.userNotLoggedIn;
    }

    final a = await dio.get(
      '/public/addfav.php',
      queryParameters: {
        'id': postId,
      },
      options: Options(
        headers: buildGelbooruSessionHeaders(
          userId: currentUserId,
          passHash: currentPassHash,
        ),
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
    final currentUserId = userId;
    final currentPassHash = passHash;
    if (currentUserId == null || currentPassHash == null) {
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
        headers: buildGelbooruSessionHeaders(
          userId: currentUserId,
          passHash: currentPassHash,
        ),
      ),
    );
  }
}
