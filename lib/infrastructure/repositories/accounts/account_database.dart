import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AccountDatabase {
  static final AccountDatabase dbProvider = AccountDatabase();

  static const databaseFileName = 'accounts.db';

  Database _db;

  Future<Database> get database async {
    if (_db != null) return _db;

    _db = await init();
    return _db;
  }

  init() async {
    final dbDirectory = await getDatabasesPath();
    // final dbDirectory = await getExternalStorageDirectory();
    print('Database path: $dbDirectory');
    Future<Database> _db = openDatabase(
        join(await getDatabasesPath(), "accounts.db"),
        version: 1,
        onCreate: (db, version) => db.execute(
            "CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, apiKey TEXT)"),
        onUpgrade: _onUpgrade);
    print('Initialized Database');
    return _db;
  }

  void _onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {
      // Do something
    }
  }
}
