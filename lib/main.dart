import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_download/file_name_generator.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:boorusama/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/infrastructure/repositories/accounts/favorite_post_repository.dart';
import 'package:boorusama/infrastructure/repositories/comments/comment_repository.dart';
import 'package:boorusama/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/infrastructure/services/scrapper_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'application/posts/post_download/download_service.dart';
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

  final defaultSetings = Setting(false, "");
  final settingRepository =
      SettingRepository(SharedPreferences.getInstance(), defaultSetings);

  runApp(App(
    postRepository:
        PostRepository(apiProvider, accountRepository, settingRepository),
    tagRepository: TagRepository(apiProvider, accountRepository),
    scrapperService: ScrapperService(),
    downloadService: DownloadService(FileNameGenerator()),
    accountRepository: accountRepository,
    noteRepository: NoteRepository(apiProvider),
    commentRepository: CommentRepository(apiProvider),
    userRepository: UserRepository(apiProvider, accountRepository),
    favoritePostRepository:
        FavoritePostRepository(apiProvider, accountRepository),
    settingRepository: settingRepository,
  ));
}
