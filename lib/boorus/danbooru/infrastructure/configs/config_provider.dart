// Package imports:
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'danbooru/config.dart';

final configProvider = Provider<IConfig>((ref) {
  return DanbooruConfig();
});
