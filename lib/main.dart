// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Package imports:
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'app.dart';
import 'boorus/danbooru/application/home/lastest/tag_list.dart';
import 'boorus/danbooru/application/settings/settings.dart';
import 'boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterDownloader.initialize(debug: false);
    }
  }

  await EasyLocalization.ensureInitialized();

  if (!kIsWeb) {
    final dbDirectory = await getApplicationDocumentsDirectory();

    Hive.init(dbDirectory.path);
  }

  final settingRepository = SettingRepository(
    Hive.openBox("settings"),
    Settings.defaultSettings,
  );

  final settings = await settingRepository.load();

  final accountBox = Hive.openBox("accounts");
  final accountRepo = AccountRepository(accountBox);

  final apiUrl = "https://safebooru.donmai.us/";
  final api = DanbooruApi(Dio(), baseUrl: apiUrl);

  final popularSearchRepo =
      PopularSearchRepository(accountRepository: accountRepo, api: api);

  final tagRepo = TagRepository(api, accountRepo);

  runApp(
    ProviderScope(
      overrides: [
        settingsNotifier.overrideWithProvider(
          StateNotifierProvider<SettingsStateNotifier>(
            (ref) => SettingsStateNotifier(
              settingRepository: settingRepository,
              setting: SettingsState(settings: settings),
            ),
          ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ITagRepository>(
            create: (_) => tagRepo,
            lazy: false,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SearchKeywordCubit(popularSearchRepo)),
          ],
          child: EasyLocalization(
            useOnlyLangCode: true,
            supportedLocales: [Locale('en', ''), Locale('vi', '')],
            path: 'assets/translations',
            fallbackLocale: Locale('en', ''),
            child: App(),
          ),
        ),
      ),
    ),
  );
}
