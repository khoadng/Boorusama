import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ReadContext;
import 'package:flutter_riverpod/all.dart';

import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/download/download_service.dart';
import 'application/themes/bloc/theme_bloc.dart';
import 'application/users/user/bloc/user_bloc.dart';
import 'domain/accounts/i_account_repository.dart';
import 'domain/users/i_user_repository.dart';
import 'infrastructure/repositories/settings/i_setting_repository.dart';
import 'infrastructure/repositories/settings/setting.dart';
import 'router.dart';

class App extends StatefulWidget {
  App({
    @required this.accountRepository,
    @required this.userRepository,
    @required this.settingRepository,
    this.settings,
  });

  final IAccountRepository accountRepository;
  final IUserRepository userRepository;
  final ISettingRepository settingRepository;
  final Setting settings;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    AppRouter().setupRoutes();

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
        BlocProvider<UserBloc>(
          lazy: false,
          create: (_) => UserBloc(
            accountRepository: widget.accountRepository,
            userRepository: widget.userRepository,
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            settingRepository: widget.settingRepository,
          ),
        ),
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
            onGenerateRoute: AppRouter.router.generator,
            title: "Boorusama",
          );
        },
      ),
    );
  }
}
