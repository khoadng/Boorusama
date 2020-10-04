import 'package:bloc/bloc.dart';
import 'package:boorusama/app.dart';
import 'package:boorusama/application/posts/post_download/download_service.dart';
import 'package:boorusama/infrastructure/posts/post_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  Bloc.observer = SimpleBlocObserver();

  runApp(App(
    postRepository: PostRepository(),
    downloadService: DownloadService(),
  ));
}
