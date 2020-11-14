import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/application/tags/tag_list/bloc/tag_list_bloc.dart';
import 'package:boorusama/application/tags/tag_suggestions/bloc/tag_suggestions_bloc.dart';
import 'package:boorusama/application/themes/bloc/theme_bloc.dart';
import 'package:boorusama/application/wikis/wiki/bloc/wiki_bloc.dart';
import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/domain/comments/i_comment_repository.dart';
import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/users/i_user_repository.dart';
import 'package:boorusama/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/authentication/services/i_scrapper_service.dart';
import 'application/comments/bloc/comment_bloc.dart';
import 'application/posts/post_list/bloc/post_list_bloc.dart';
import 'application/posts/post_translate_note/bloc/post_translate_note_bloc.dart';
import 'application/users/bloc/user_list_bloc.dart';
import 'application/users/user/bloc/user_bloc.dart';
import 'infrastructure/repositories/settings/setting.dart';
import 'presentation/posts/post_list/post_list_page.dart';

class App extends StatefulWidget {
  App({
    @required this.postRepository,
    @required this.downloadService,
    @required this.scrapperService,
    @required this.tagRepository,
    @required this.noteRepository,
    @required this.favoritePostRepository,
    @required this.accountRepository,
    @required this.userRepository,
    @required this.settingRepository,
    @required this.wikiRepository,
    @required this.commentRepository,
    this.settings,
  });

  final IPostRepository postRepository;
  final ITagRepository tagRepository;
  final INoteRepository noteRepository;
  final IAccountRepository accountRepository;
  final IDownloadService downloadService;
  final IScrapperService scrapperService;
  final IFavoritePostRepository favoritePostRepository;
  final ICommentRepository commentRepository;
  final IUserRepository userRepository;
  final ISettingRepository settingRepository;
  final IWikiRepository wikiRepository;
  final Setting settings;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostListBloc>(
          lazy: false,
          create: (_) => PostListBloc(
            postSearchBloc: BlocProvider.of<PostSearchBloc>(context),
          ),
        ),
        BlocProvider<PostDownloadBloc>(
          create: (_) => PostDownloadBloc(
              widget.downloadService..init(Theme.of(context).platform)),
        ),
        BlocProvider<TagSuggestionsBloc>(
            create: (_) => TagSuggestionsBloc(widget.tagRepository)),
        BlocProvider<PostTranslateNoteBloc>(
            create: (_) => PostTranslateNoteBloc(widget.noteRepository)),
        BlocProvider<TagListBloc>(
            create: (_) => TagListBloc(widget.tagRepository)),
        BlocProvider<PostFavoritesBloc>(
            create: (_) => PostFavoritesBloc(
                widget.postRepository, widget.favoritePostRepository)),
        BlocProvider<CommentBloc>(
            create: (_) => CommentBloc(widget.commentRepository)),
        BlocProvider<UserListBloc>(
            create: (_) => UserListBloc(widget.userRepository)),
        BlocProvider<UserBloc>(
            create: (_) =>
                UserBloc(widget.accountRepository, widget.userRepository)),
        BlocProvider<WikiBloc>(create: (_) => WikiBloc(widget.wikiRepository)),
        BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc()
              ..add(ThemeChanged(theme: widget.settings.themeMode))),
        BlocProvider<AuthenticationBloc>(
            lazy: false,
            create: (_) => AuthenticationBloc(
                scrapperService: widget.scrapperService,
                accountRepository: widget.accountRepository)
              ..add(AuthenticationRequested())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
              appBarTheme:
                  AppBarTheme(iconTheme: IconThemeData(color: state.iconColor)),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            themeMode: state.theme,
            debugShowCheckedModeBanner: false,
            title: "Boorusama",
            home: PostListPage(),
          );
        },
      ),
    );
  }
}
