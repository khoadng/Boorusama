// Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/i_profile_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final profileProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    accountRepository: ref.watch(accountProvider),
    api: ref.watch(apiProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  ProfileRepository({@required IAccountRepository accountRepository, @required IApi api})
      : _api = api,
        _accountRepository = accountRepository;

  final IAccountRepository _accountRepository;
  final IApi _api;

  @override
  Future<Profile> getProfile({
    CancelToken cancelToken,
    String apiKey,
    String username,
  }) async {
    var value;
    try {
      if (apiKey != null && username != null) {
        value = await _api.getProfile(username, apiKey, cancelToken: cancelToken);
      } else {
        final account = await _accountRepository.get();
        value = await _api.getProfile(account.username, account.apiKey, cancelToken: cancelToken);
      }
      return Profile.fromJson(value.response.data);
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return null;
      } else {
        throw InvalidUsernameOrPassword();
      }
    }
  }
}

class InvalidUsernameOrPassword implements Exception {}
