// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

class AccountRepositoryDev implements IAccountRepository {
  AccountRepositoryDev({
    required this.account,
  });

  final Account account;

  @override
  Future<void> add(Account account) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String username) {
    throw UnimplementedError();
  }

  @override
  Future<Account> get() async => account;

  @override
  Future<List<Account>> getAll() async => [account];

  @override
  Future<void> remove(int accountId) {
    throw UnimplementedError();
  }
}
