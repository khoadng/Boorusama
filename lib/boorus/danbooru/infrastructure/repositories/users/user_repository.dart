// Package imports:
import 'package:boorusama/boorus/danbooru/domain/users/user_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_level.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final userProvider = Provider<UserRepository>((ref) =>
    UserRepository(ref.watch(apiProvider), ref.watch(accountProvider)));

class UserRepository implements IUserRepository {
  UserRepository(this._api, this._accountRepository);

  final IAccountRepository _accountRepository;
  final IApi _api;

  @override
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  }) async {
    try {
      final value = await _api.getUsersByIdStringComma(idComma, 1000,
          cancelToken: cancelToken);

      var users = <User>[];
      print(idComma);
      for (var item in value.response.data) {
        try {
          var dto = UserDto.fromJson(item);
          var user = User(dto.id, dto.name, UserLevel(dto.level), '');
          users.add(user);
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
      return users;
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception("Failed to get users for $idComma");
      }
    }
  }

  @override
  Future<User> getUserById(int id) async {
    final account = await _accountRepository.get();
    return _api.getUserById(account.username, account.apiKey, id).then((value) {
      var dto = UserDto.fromJson(value.response.data);
      var user = User(dto.id, dto.name, UserLevel(dto.level), '');
      return user;
    }).catchError((Object obj) {
      throw Exception("Failed to get user info for $id");
    });
  }
}
