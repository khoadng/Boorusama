// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/reports/danbooru_report_repository.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruPostReportProvider =
    Provider.family<DanbooruReportRepository, BooruConfig>((ref, config) {
  return DanbooruReportRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});
