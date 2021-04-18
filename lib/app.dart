// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'app_constants.dart';
import 'boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'boorus/danbooru/domain/accounts/account.dart';
import 'boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'boorus/danbooru/infrastructure/services/download_service.dart';
import 'boorus/danbooru/router.dart';
import 'core/app_theme.dart';
import 'generated/i18n.dart';

class App extends StatefulWidget {
  App();

  @override
  _AppState createState() => _AppState();
}

final _language = Provider<Locale>((ref) {
  final lang = ref.watch(settingsNotifier.state).settings.language;
  return Locale(lang);
});

final _accountState = Provider<AccountState>((ref) {
  return ref.watch(authenticationStateNotifierProvider.state).state;
});
final _account = Provider<Account>((ref) {
  return ref.watch(authenticationStateNotifierProvider.state).account;
});

final blacklistedTagsProvider = FutureProvider<List<String>>((ref) async {
  final accountState = ref.watch(_accountState);
  final userRepository = ref.watch(userProvider);
  var blacklistedTags = <String>[];

  if (accountState == AccountState.loggedIn()) {
    final account = ref.watch(_account);
    final user = await userRepository.getUserById(account.id);

    blacklistedTags = user.blacklistedTags;
  }

  return blacklistedTags;
});

class _AppState extends State<App> {
  final i18n = I18n.delegate;

  @override
  void initState() {
    super.initState();

    AppRouter().setupRoutes();

    if (Platform.isAndroid || Platform.isIOS) {
      Future.delayed(
          Duration.zero, () => context.read(downloadServiceProvider).init());
    }

    // Future.delayed(
    //     Duration.zero,
    //     () => context
    //         .read(themeStateNotifierProvider)
    //         .changeTheme(widget.settings.themeMode));

    I18n.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderListener(
      provider: blacklistedTagsProvider,
      onChange: (context, tags) {
        tags.whenData((data) {
          final settings = context.read(settingsNotifier.state).settings;

          settings.blacklistedTags = data.join("\n");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read(settingsNotifier).save(settings);
          });
        });
      },
      child: Consumer(
        builder: (_, watch, __) {
          final locale = watch(_language);

          return Portal(
            child: MaterialApp(
              builder: (context, child) => ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: child,
              ),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.dark,
              localizationsDelegates: [
                i18n,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              locale: locale,
              supportedLocales: i18n.supportedLocales,
              localeResolutionCallback:
                  i18n.resolution(fallback: Locale("en", "US")),
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.router.generator,
              title: AppConstants.appName,
            ),
          );
        },
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
