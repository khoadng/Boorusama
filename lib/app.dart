import 'package:boorusama/application/accounts/add_account/bloc/add_account_bloc.dart';
import 'package:boorusama/application/accounts/add_account/services/i_scrapper_service.dart';
import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/posts/post_list/bloc/post_list_bloc.dart';
import 'application/posts/post_translate_note/bloc/post_translate_note_bloc.dart';
import 'presentation/posts/post_list/post_list_page.dart';

class App extends StatelessWidget {
  App(
      {@required this.postRepository,
      @required this.downloadService,
      @required this.scrapperService,
      @required this.tagRepository,
      @required this.noteRepository,
      @required this.accountRepository});

  final IPostRepository postRepository;
  final ITagRepository tagRepository;
  final INoteRepository noteRepository;
  final IAccountRepository accountRepository;
  final IDownloadService downloadService;
  final IScrapperService scrapperService;

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
        BlocProvider<AddAccountBloc>(
            create: (_) => AddAccountBloc(
                accountRepository: accountRepository,
                scrapperService: scrapperService)),
        BlocProvider<GetAllAccountsBloc>(
            create: (_) => GetAllAccountsBloc(accountRepository)),
        BlocProvider<RemoveAccountBloc>(
            create: (_) => RemoveAccountBloc(accountRepository)),
        BlocProvider<PostTranslateNoteBloc>(
            create: (_) => PostTranslateNoteBloc(noteRepository)),
        BlocProvider<TagListBloc>(create: (_) => TagListBloc(tagRepository)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          /* light theme settings */
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.dark,
        /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
        debugShowCheckedModeBanner: false,
        title: "Boorusama",
        home: PostListPage(),
      ),
    );
  }
}
