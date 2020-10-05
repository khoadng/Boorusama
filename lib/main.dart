import 'package:bloc/bloc.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:boorusama/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/infrastructure/services/scrapper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'application/posts/post_download/download_service.dart';
import 'bloc_observer.dart';
import 'infrastructure/repositories/posts/post_repository.dart';

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

  final apiProvider = Danbooru(http.Client());

  runApp(App(
    postRepository: PostRepository(apiProvider),
    tagRepository: TagRepository(apiProvider),
    scrapperService: ScrapperService(),
    downloadService: DownloadService(),
    accountRepository: AccountRepository(accountDb),
  ));
}
