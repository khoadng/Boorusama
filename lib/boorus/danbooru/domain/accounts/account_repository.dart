// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

abstract class AccountRepository {
  Future<void> add(Account account);
  Future<void> remove(int accountId);
  Future<List<Account>> getAll();
  Future<Account> get();
  Future<bool> exists(String username);
}
