// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profiles.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';

class ProfileRepositoryApi implements ProfileRepository {
  ProfileRepositoryApi({
    required AccountRepository accountRepository,
    required Api api,
  })  : _api = api,
        _accountRepository = accountRepository;

  final AccountRepository _accountRepository;
  final Api _api;

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
        final account = await _accountRepository.get();
        value = await _api.getProfile(account.username, account.apiKey,
            cancelToken: cancelToken);
      }
      return profileDtoToProfile(ProfileDto.fromJson(value.response.data));
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return null;
      } else {
        throw InvalidUsernameOrPassword();
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
