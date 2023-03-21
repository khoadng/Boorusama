// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';

class ProfileRepositoryApi implements ProfileRepository {
  ProfileRepositoryApi({
    required CurrentUserBooruRepository currentUserBooruRepository,
    required DanbooruApi api,
  })  : _api = api,
        _currentUserBooruRepository = currentUserBooruRepository;

  final CurrentUserBooruRepository _currentUserBooruRepository;
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
        final userBooru = await _currentUserBooruRepository.get();
        value = await _api.getProfile(
          userBooru?.login,
          userBooru?.apiKey,
          cancelToken: cancelToken,
        );
      }

      return profileDtoToProfile(ProfileDto.fromJson(value.response.data));
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
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
