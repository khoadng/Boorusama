// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  CurrentBooruConfigNotifier.new,
  dependencies: [
    settingsProvider,
    loggerProvider,
    initialSettingsBooruConfigProvider,
  ],
  name: 'currentBooruConfigProvider',
);

final initialSettingsBooruConfigProvider = Provider<BooruConfig>(
  (ref) => throw UnimplementedError(),
  name: 'initialSettingsBooruConfigProvider',
);
