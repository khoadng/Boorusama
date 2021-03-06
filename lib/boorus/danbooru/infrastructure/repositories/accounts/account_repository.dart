// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'account_database.dart';

final accountProvider = Provider<IAccountRepository>((ref) {
  return AccountRepository(AccountDatabase.dbProvider.database);
});

class AccountRepository implements IAccountRepository {
  final Future<Database> _db;

  AccountRepository(this._db);

  @override
  Future<void> add(Account account) async {
    final db = await _db;

    await db.insert("accounts", account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<bool> exists(String username) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAll() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query("accounts");

    return List.generate(maps.length, (i) {
      return Account.create(
          maps[i]['username'], maps[i]['apiKey'], maps[i]['id']);
    });
  }

  @override
  Future<void> remove(int accountId) async {
    final db = await _db;

    await db.delete("accounts", where: "id = ?", whereArgs: [accountId]);
  }

  @override
  Future<Account> get() async {
    final db = await _db;

    final List<Map<String, dynamic>> records = await db.query('accounts');

    if (records == null || records.isEmpty) {
      return Account.empty;
    }

    return Account.create(records.first['username'], records.first['apiKey'],
        records.first['id']);
  }
}
