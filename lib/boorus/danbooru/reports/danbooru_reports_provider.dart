// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/reports/danbooru_report_repository.dart';
import 'package:boorusama/core/configs/configs.dart';

final danbooruPostReportProvider =
    Provider.family<DanbooruReportRepository, BooruConfig>((ref, config) {
  return DanbooruReportRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});
