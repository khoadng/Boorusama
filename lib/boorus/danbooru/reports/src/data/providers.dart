// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../client_provider.dart';
import '../types/danbooru_report_repository.dart';
import 'danbooru_report_repository_api.dart';

final danbooruPostReportProvider =
    Provider.family<DanbooruReportRepository, BooruConfigAuth>((ref, config) {
  return DanbooruReportRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});
