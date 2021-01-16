import 'package:boorusama/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ReadContext;
import 'package:flutter_riverpod/all.dart';

import 'application/authentication/bloc/authentication_bloc.dart';
import 'application/download/download_service.dart';
import 'application/themes/theme_state_notifier.dart';
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

    Future.delayed(
        Duration.zero,
        () => context
            .read(themeStateNotifierProvider)
            .changeTheme(widget.settings.themeMode));
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
      ],
      child: ProviderListener<ThemeState>(
        provider: themeStateNotifierProvider.state,
        onChange: (context, state) {
          state.when(
            darkMode: () async {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.grey[900],
                statusBarColor: Colors.grey[900],
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
              ));
            },
            lightMode: () async {
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.white,
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.dark,
              ));
            },
          );
        },
        child: Consumer(
          builder: (context, watch, child) {
            final state = watch(themeStateNotifierProvider.state);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.when(
                darkMode: () => ThemeMode.dark,
                lightMode: () => ThemeMode.light,
              ),
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.router.generator,
              title: "Boorusama",
            );
          },
        ),
      ),
    );
  }
}
