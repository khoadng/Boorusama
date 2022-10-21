// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

class AccountRepositoryDev implements AccountRepository {
  AccountRepositoryDev({
    required this.account,
  });

  final Account account;

  @override
  // ignore: no-empty-block
  Future<void> add(Account account) async {}

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
