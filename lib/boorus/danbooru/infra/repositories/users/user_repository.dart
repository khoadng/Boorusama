// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<User> parseUser(
  HttpResponse<dynamic> value,
) =>
    parse(
      value: value,
      converter: (item) => UserDto.fromJson(item),
    ).map((u) => userDtoToUser(u)).toList();

List<UserSelf> parseUserSelf(
  HttpResponse<dynamic> value,
  List<String> defaultBlacklistedTags,
) =>
    parse(
      value: value,
      converter: (item) => UserSelfDto.fromJson(item),
    ).map((u) => userDtoToUserSelf(u, defaultBlacklistedTags)).toList();

class UserRepositoryApi implements UserRepository {
  UserRepositoryApi(
    this._api,
    this._accountRepository,
    this.defaultBlacklistedTags,
  );

  final AccountRepository _accountRepository;
  final DanbooruApi _api;
  final List<String> defaultBlacklistedTags;

  @override
  Future<List<User>> getUsersByIdStringComma(
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
          .then((u) => parseUser(u));
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
  Future<User> getUserById(int id) => _accountRepository
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
      .then((d) => userDtoToUser(d));

  @override
  Future<UserSelf?> getUserSelfById(int id) => _accountRepository
      .get()
      .then(
        (account) => _api.getUserById(
          account.username,
          account.apiKey,
          id,
        ),
      )
      .then((value) => Map<String, dynamic>.from(value.response.data))
      .then((e) => UserSelfDto.fromJson(e))
      .then((d) => userDtoToUserSelf(d, defaultBlacklistedTags));
}

User userDtoToUser(
  UserDto d,
) {
  try {
    return User(
      id: d.id!,
      level: intToUserLevel(d.level!),
      name: d.name!,
      joinedDate: d.createdAt!,
      uploadCount: d.uploadCount ?? 0,
      tagEditCount: d.tagEditCount ?? 0,
      noteEditCount: d.noteEditCount ?? 0,
      commentCount: d.commentCount ?? 0,
      forumPostCount: d.forumPostCount ?? 0,
      favoriteGroupCount: d.favoriteGroupCount ?? 0,
    );
  } catch (e, stackTrace) {
    Error.throwWithStackTrace(
      Exception('fail to parse one of the required field\n $e'),
      stackTrace,
    );
  }
}

UserSelf userDtoToUserSelf(
  UserSelfDto d,
  List<String> defaultBlacklistedTags,
) {
  try {
    return UserSelf(
      id: d.id!,
      level: intToUserLevel(d.level!),
      name: d.name!,
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
