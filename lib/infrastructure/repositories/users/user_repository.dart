import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/users/user.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class UserRepository implements IUserRepository {
  final Danbooru _api;
  final IAccountRepository _accountRepository;

  UserRepository(this._api, this._accountRepository);

  @override
  Future<List<User>> getUsersByIdStringComma(String idComma) async {
    //TODO: should hardcode limit parameter
    var uri = Uri.https(_api.url, "/users.json", {
      "search[id]": idComma,
      "limit": "1000",
    });

    var users = List<User>();
    try {
      final respond = await _api.dio.get(uri.toString());

      for (var item in respond.data) {
        try {
          users.add(User.fromJson(item));
        } catch (e) {
          print("Cant parse ${item['id']}");
        }
      }
    } on DioError catch (e) {
      // if (e.response.statusCode == 422) {
      //   throw CannotSearchMoreThanTwoTags(
      //       "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      // }
    }

    return users;
  }

  @override
  Future<User> getUserById(int id) async {
    final account = await _accountRepository.get();
    //TODO: should hardcode limit parameter
    var uri = Uri.https(_api.url, "/users/$id.json", {
      "login": account.username,
      "api_key": account.apiKey,
    });

    var users = List<User>();
    try {
      final respond = await _api.dio.get(
        uri.toString(),
        options: buildCacheOptions(
          Duration(
            days: 90,
          ),
        ),
      );

      try {
        users.add(User.fromJson(respond.data));
      } catch (e) {
        print("Cant parse ${respond.data['id']}");
      }
    } on DioError catch (e) {
      // if (e.response.statusCode == 422) {
      //   throw CannotSearchMoreThanTwoTags(
      //       "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      // }
    }

    return users.first;
  }
}
