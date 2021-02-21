// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/users/user_repository.dart';
import 'setting.dart';

final _accountState = Provider<AccountState>((ref) {
  return ref.watch(authenticationStateNotifierProvider.state).state;
});
final _account = Provider<Account>((ref) {
  return ref.watch(authenticationStateNotifierProvider.state).account;
});
final settingsProvider = FutureProvider<ISettingRepository>((ref) async {
  final accountState = ref.watch(_accountState);
  final userRepository = ref.watch(userProvider);
  final repo = SettingRepository(
    SharedPreferences.getInstance(),
    Setting.defaultSettings,
  );

  if (accountState == AccountState.loggedIn()) {
    final account = ref.watch(_account);
    final user = await userRepository.getUserById(account.id);

    final blacklistedTags = user.blacklistedTags.join("\n");
    final settings = await repo.load();
    settings.blacklistedTags = blacklistedTags;
    await repo.save(settings);
  }

  return repo;
});

final blacklistedTagsProvider = FutureProvider<List<String>>((ref) async {
  final settingsRepository = await ref.watch(settingsProvider.future);
  final settings = await settingsRepository.load();

  return settings.blacklistedTags.split("\n");
});

class SettingRepository implements ISettingRepository {
  final Future<SharedPreferences> _prefs;
  final Setting _defaultSetting;

  SettingRepository(this._prefs, this._defaultSetting);

  @override
  Future<Setting> load() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString("settings");

    if (jsonString == null) {
      return _defaultSetting;
    }

    final json = jsonDecode(jsonString);
    final settings = Setting.fromJson(json);

    return settings;
  }

  @override
  Future<bool> save(Setting setting) async {
    final prefs = await _prefs;
    final json = jsonEncode(setting.toJson());

    //TODO: should make general name instead
    final success = await prefs.setString("settings", json);

    return success;
  }
}
