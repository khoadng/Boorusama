import 'package:bloc/bloc.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_database.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/scrapper_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'bloc_observer.dart';
import 'boorus/danbooru/application/authentication/bloc/authentication_bloc.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'boorus/danbooru/infrastructure/repositories/users/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  final Future<Database> accountDb = openDatabase(
    join(await getDatabasesPath(), "accounts.db"),
    onCreate: (db, version) => db.execute(
        "CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, apiKey TEXT)"),
    version: 1,
  );

  AccountDatabase.dbProvider.init();

  Bloc.observer = SimpleBlocObserver();

  final accountRepository = AccountRepository(accountDb);

  final url = "https://danbooru.donmai.us/";
  final dio = Dio()
    ..interceptors.add(DioCacheManager(CacheConfig(baseUrl: url)).interceptor);
  final api = DanbooruApi(dio, baseUrl: url);

  final settingRepository = SettingRepository(
    SharedPreferences.getInstance(),
    Setting.defaultSettings,
  );

  final settings = await settingRepository.load();

  runApp(
    provider.MultiProvider(
      providers: [
        provider.Provider<SettingRepository>(
          create: (context) => settingRepository,
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            lazy: false,
            create: (_) => AuthenticationBloc(
              scrapperService: ScrapperService(url),
              accountRepository: accountRepository,
            )..add(AuthenticationRequested()),
          ),
        ],
        child: ProviderScope(
          child: App(
            settings: settings,
            accountRepository: accountRepository,
            userRepository: UserRepository(api, accountRepository),
            settingRepository: settingRepository,
          ),
        ),
      ),
    ),
  );
}
