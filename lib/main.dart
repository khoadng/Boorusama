import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_download/file_name_generator.dart';
import 'package:boorusama/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:boorusama/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/infrastructure/repositories/accounts/favorite_post_repository.dart';
import 'package:boorusama/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/infrastructure/repositories/wikis/wiki_repository.dart';
import 'package:boorusama/infrastructure/services/scrapper_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/posts/post_download/download_service.dart';
import 'application/posts/post_search/bloc/post_search_bloc.dart';
import 'bloc_observer.dart';
import 'infrastructure/repositories/posts/post_repository.dart';
import 'infrastructure/repositories/settings/setting.dart';
import 'infrastructure/repositories/users/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  final Future<Database> accountDb = openDatabase(
    join(await getDatabasesPath(), "accounts.db"),
    onCreate: (db, version) => db.execute(
        "CREATE TABLE accounts(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, apiKey TEXT)"),
    version: 1,
  );

  Bloc.observer = SimpleBlocObserver();

  final apiProvider = Danbooru(Dio());
  final accountRepository = AccountRepository(accountDb);

  final url = "https://danbooru.donmai.us/";
  final dio = Dio();
  dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: url)).interceptor);
  final api = DanbooruApi(dio, baseUrl: url);

  final settingRepository = SettingRepository(
    SharedPreferences.getInstance(),
    Setting.defaultSettings,
  );

  final postRepository = PostRepository(
    apiProvider,
    accountRepository,
    settingRepository,
  );

  final settings = await settingRepository.load();

  runApp(MultiProvider(
    providers: [
      Provider<SettingRepository>(
        create: (context) => settingRepository,
      )
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          lazy: false,
          create: (_) => AuthenticationBloc(
            scrapperService: ScrapperService(apiProvider),
            accountRepository: accountRepository,
          )..add(AuthenticationRequested()),
        ),
        BlocProvider(
          create: (_) => PostSearchBloc(
            postRepository: postRepository,
          ),
        ),
      ],
      child: App(
        settings: settings,
        postRepository: postRepository,
        tagRepository: TagRepository(apiProvider, accountRepository),
        downloadService: DownloadService(FileNameGenerator()),
        accountRepository: accountRepository,
        noteRepository: NoteRepository(apiProvider),
        commentRepository: CommentRepository(api, accountRepository),
        userRepository: UserRepository(apiProvider, accountRepository),
        favoritePostRepository: FavoritePostRepository(api, accountRepository),
        settingRepository: settingRepository,
        wikiRepository: WikiRepository(apiProvider),
      ),
    ),
  ));
}
