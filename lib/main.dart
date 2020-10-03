import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/infrastructure/posts/post_repository.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Danbooru",
        home: BlocProvider(
          create: (context) => PostListBloc(PostRepository()),
          child: PostListPage(),
        ));
  }
}
