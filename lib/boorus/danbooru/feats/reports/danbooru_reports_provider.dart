// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/reports/danbooru_report_repository.dart';

final danbooruPostReportProvider = Provider<DanbooruReportRepository>((ref) {
  return DanbooruReportRepositoryApi(
    danbooruApi: ref.watch(danbooruApiProvider),
  );
});
