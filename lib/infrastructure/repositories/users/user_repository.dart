import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';

class UserRepository implements IUserRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  UserRepository(this._api, this._accountRepository);

  @override
  Future<List<User>> getUsersByIdStringComma(String idComma) async =>
      _api.getUsersByIdStringComma(idComma, 1000).then((value) {
        var users = List<User>();
        for (var item in value.response.data) {
          try {
            users.add(User.fromJson(item));
          } catch (e) {
            print("Cant parse ${item['id']}");
          }
          return users;
        }
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
