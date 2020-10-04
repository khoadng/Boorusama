import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_download/download_service.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/posts/post_list/bloc/post_list_bloc.dart';

class App extends StatelessWidget {
  App(
      {@required this.postRepository,
      @required this.downloadService,
      @required this.tagRepository});

  final IPostRepository postRepository;
  final ITagRepository tagRepository;
  final IDownloadService downloadService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostListBloc>(
          create: (_) => PostListBloc(
            repository: postRepository,
          ),
        ),
        BlocProvider<PostDownloadBloc>(
          create: (_) => PostDownloadBloc(
              downloadService..init(Theme.of(context).platform)),
        ),
        BlocProvider<TagSuggestionsBloc>(
            create: (_) => TagSuggestionsBloc(tagRepository)),
      ],
      child: MaterialApp(
        title: "Boorusama",
        home: PostListPage(),
      ),
    );
  }
}
