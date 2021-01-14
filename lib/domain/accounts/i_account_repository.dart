import 'package:boorusama/domain/accounts/account.dart';

abstract class IAccountRepository {
  Future<void> add(Account account);
  Future<void> remove(int accountId);
  Future<List<Account>> getAll();
  Future<Account> get();
  Future<bool> exists(String username);
}
