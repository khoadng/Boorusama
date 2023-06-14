// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/danbooru/feats/profile/models/profile.dart';
import 'package:boorusama/boorus/danbooru/feats/profile/profile.dart';

class ProfileRepositoryApi implements ProfileRepository {
  ProfileRepositoryApi({
    required this.booruConfig,
    required DanbooruApi api,
  }) : _api = api;

  final BooruConfig booruConfig;
  final DanbooruApi _api;

  @override
  Future<Profile?> getProfile({
    CancelToken? cancelToken,
    String? apiKey,
    String? username,
  }) async {
    HttpResponse value;
    try {
      if (apiKey != null && username != null) {
        value =
            await _api.getProfile(username, apiKey, cancelToken: cancelToken);
      } else {
        value = await _api.getProfile(
          booruConfig.login,
          booruConfig.apiKey,
          cancelToken: cancelToken,
        );
      }

      return profileDtoToProfile(ProfileDto.fromJson(value.response.data));
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return null;
      } else {
        Error.throwWithStackTrace(
          InvalidUsernameOrPassword(),
          stackTrace,
        );
      }
    }
  }
}

Profile profileDtoToProfile(ProfileDto d) => Profile(
      id: d.id,
      lastLoggedInAt: d.lastLoggedInAt,
      name: d.name,
      level: d.level,
      favoriteCount: d.favoriteCount,
      levelString: d.levelString,
      commentCount: d.commentCount,
      inviterId: d.inviterId,
    );
