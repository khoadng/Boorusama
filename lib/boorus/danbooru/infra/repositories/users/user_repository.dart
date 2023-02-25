// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<UserSelf> parseUser(
  HttpResponse<dynamic> value,
  List<String> defaultBlacklistedTags,
) =>
    parse(
      value: value,
      converter: (item) => UserDto.fromJson(item),
    ).map((u) => userDtoToUser(u, defaultBlacklistedTags)).toList();

class UserRepositoryApi implements UserRepository {
  UserRepositoryApi(
    this._api,
    this._accountRepository,
    this.defaultBlacklistedTags,
  );

  final AccountRepository _accountRepository;
  final Api _api;
  final List<String> defaultBlacklistedTags;

  @override
  Future<List<UserSelf>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getUsersByIdStringComma(
            idComma,
            1000,
            cancelToken: cancelToken,
          )
          .then((u) => parseUser(u, defaultBlacklistedTags));
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get users for $idComma'),
          stackTrace,
        );
      }
    }
  }

  @override
  Future<UserSelf> getUserById(int id) => _accountRepository
      .get()
      .then(
        (account) => _api.getUserById(
          account.username,
          account.apiKey,
          id,
        ),
      )
      .then((value) => Map<String, dynamic>.from(value.response.data))
      .then((e) => UserDto.fromJson(e))
      .then((d) => userDtoToUser(d, defaultBlacklistedTags));

  @override
  Future<void> setUserBlacklistedTags(int id, String blacklistedTags) =>
      _accountRepository.get().then(
            (account) => _api.setBlacklistedTags(
              account.username,
              account.apiKey,
              id,
              blacklistedTags,
            ),
          );
}

UserSelf userDtoToUser(
  UserDto d,
  List<String> defaultBlacklistedTags,
) {
  try {
    return UserSelf(
      id: d.id!,
      level: intToUserLevel(d.level!),
      name: d.name!,
      //TODO: need to find a way to distinguish between other user and current user.
      blacklistedTags: d.blacklistedTags == null
          ? defaultBlacklistedTags
          : tagStringToListTagString(d.blacklistedTags!),
    );
  } catch (e, stackTrace) {
    Error.throwWithStackTrace(
      Exception('fail to parse one of the required field\n $e'),
      stackTrace,
    );
  }
}
