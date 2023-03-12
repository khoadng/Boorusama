// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';

class AccountRepositoryApi implements AccountRepository {
  AccountRepositoryApi(this._db);
  final Future<Box> _db;

  @override
  Future<void> add(Account account) async {
    final db = await _db;

    await db.put('accounts', account.toMap());
  }

  @override
  Future<bool> exists(String username) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAll() async {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(int accountId) async {
    final db = await _db;

    await db.delete('accounts');
  }

  @override
  Future<Account> get() async {
    final db = await _db;

    final record = db.get('accounts');

    if (record == null) {
      return Account.empty;
    }

    return Account.create(
      record['username'],
      record['apiKey'],
      record['id'],
      record['booru'],
    );
  }
}
