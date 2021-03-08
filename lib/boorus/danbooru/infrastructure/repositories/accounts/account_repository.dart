// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';

final accountProvider = Provider<IAccountRepository>((ref) {
  final box = Hive.openBox("accounts");
  return AccountRepository(box);
});

class AccountRepository implements IAccountRepository {
  final Future<Box> _db;

  AccountRepository(this._db);

  @override
  Future<void> add(Account account) async {
    final db = await _db;

    db.put("accounts", account.toMap());
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

    return Account.create(record['username'], record['apiKey'], record['id']);
  }
}
