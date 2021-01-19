import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:flutter_riverpod/all.dart';

final userProvider = Provider<UserRepository>((ref) =>
    UserRepository(ref.watch(apiProvider), ref.watch(accountProvider)));

class UserRepository implements IUserRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  UserRepository(this._api, this._accountRepository);

  @override
  Future<List<User>> getUsersByIdStringComma(String idComma) async =>
      _api.getUsersByIdStringComma(idComma, 1000).then((value) {
        var users = List<User>();
        print(idComma);
        for (var item in value.response.data) {
          try {
            users.add(User.fromJson(item));
          } catch (e) {
            print("Cant parse ${item['id']}");
          }
        }
        return users;
      }).catchError((Object obj) {
        throw Exception("Failed to get users for $idComma");
      });

  @override
  Future<User> getUserById(int id) async {
    final account = await _accountRepository.get();
    return _api.getUserById(account.username, account.apiKey, id).then((value) {
      //TODO: why did I use a list of users??
      var users = List<User>();
      try {
        users.add(User.fromJson(value.response.data));
      } catch (e) {
        print("Cant parse $id");
      }
      return users.first;
    }).catchError((Object obj) {
      throw Exception("Failed to get user info for $id");
    });
  }
}
