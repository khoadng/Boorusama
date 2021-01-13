import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ReadContext;
import 'package:flutter_riverpod/all.dart';

import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/download/download_service.dart';
import 'application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'application/themes/bloc/theme_bloc.dart';
import 'application/users/user/bloc/user_bloc.dart';
import 'application/wikis/wiki/bloc/wiki_bloc.dart';
import 'domain/accounts/i_account_repository.dart';
import 'domain/accounts/i_favorite_post_repository.dart';
import 'domain/comments/i_comment_repository.dart';
import 'domain/posts/i_note_repository.dart';
import 'domain/posts/i_post_repository.dart';
import 'domain/tags/i_tag_repository.dart';
import 'domain/users/i_user_repository.dart';
import 'domain/wikis/i_wiki_repository.dart';
import 'infrastructure/repositories/settings/i_setting_repository.dart';
import 'infrastructure/repositories/settings/setting.dart';
import 'presentation/home/home_page.dart';

class App extends StatefulWidget {
  App({
    @required this.postRepository,
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
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => context
            .read(downloadServiceProvider)
            .init(Theme.of(context).platform));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostFavoritesBloc>(
            create: (_) => PostFavoritesBloc(
                  widget.postRepository,
                  widget.favoritePostRepository,
                  widget.settingRepository,
                )),
        BlocProvider<UserBloc>(
          lazy: false,
          create: (_) => UserBloc(
            accountRepository: widget.accountRepository,
            userRepository: widget.userRepository,
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            settingRepository: widget.settingRepository,
          ),
        ),
        BlocProvider<WikiBloc>(create: (_) => WikiBloc(widget.wikiRepository)),
        BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc()
              ..add(ThemeChanged(theme: widget.settings.themeMode))),
      ],
      child: BlocConsumer<ThemeBloc, ThemeState>(
        listener: (context, state) {
          // WidgetsBinding.instance.addPostFrameCallback((_) async {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: state.appBarColor,
              statusBarBrightness: state.statusBarIconBrightness,
              statusBarIconBrightness: state.statusBarIconBrightness));
          // });
        },
        builder: (context, state) {
          return MaterialApp(
            theme: ThemeData(
              primaryTextTheme: Theme.of(context)
                  .textTheme
                  .copyWith(headline6: TextStyle(color: Colors.black)),
              appBarTheme: AppBarTheme(
                  brightness: state.appBarBrightness,
                  iconTheme: IconThemeData(color: state.iconColor),
                  color: state.appBarColor),
              iconTheme: IconThemeData(color: state.iconColor),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primaryTextTheme: Theme.of(context)
                  .textTheme
                  .copyWith(headline6: TextStyle(color: Colors.white)),
              appBarTheme: AppBarTheme(
                  brightness: state.appBarBrightness,
                  iconTheme: IconThemeData(color: state.iconColor),
                  color: state.appBarColor),
              iconTheme: IconThemeData(color: state.iconColor),
              brightness: Brightness.dark,
            ),
            themeMode: state.theme,
            debugShowCheckedModeBanner: false,
            title: "Boorusama",
            home: HomePage(),
          );
        },
      ),
    );
  }
}
