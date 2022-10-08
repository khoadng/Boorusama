// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';

class ProfileRepository implements IProfileRepository {
  ProfileRepository(
      {required IAccountRepository accountRepository, required Api api})
      : _api = api,
        _accountRepository = accountRepository;

  final IAccountRepository _accountRepository;
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
      return Profile.fromJson(value.response.data);
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

class InvalidUsernameOrPassword implements Exception {}
