import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ReadContext;
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_constants.dart';
import 'boorus/danbooru/application/authentication/bloc/authentication_bloc.dart';
import 'boorus/danbooru/application/download/download_service.dart';
import 'boorus/danbooru/application/themes/theme_state_notifier.dart';
import 'boorus/danbooru/application/users/user/bloc/user_bloc.dart';
import 'boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'boorus/danbooru/domain/users/i_user_repository.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'core/app_theme.dart';
import 'generated/i18n.dart';
import 'boorus/danbooru/router.dart';

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
  final i18n = I18n.delegate;

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

    I18n.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
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
              localizationsDelegates: [
                i18n,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              locale: Locale(widget.settings.language),
              supportedLocales: i18n.supportedLocales,
              localeResolutionCallback:
                  i18n.resolution(fallback: Locale("en", "US")),
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.router.generator,
              title: AppConstants.appName,
            );
          },
        ),
      ),
    );
  }
}
