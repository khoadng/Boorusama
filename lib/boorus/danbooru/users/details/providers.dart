// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/posts/post_repository.dart';
import 'package:boorusama/core/tags/categories/tag_category.dart';
import '../../posts/post/danbooru_post.dart';
import '../../posts/post/providers.dart';
import '../../reports/danbooru_report_data_point.dart';
import '../../reports/danbooru_report_period.dart';
import '../../reports/providers.dart';
import '../../tags/related/danbooru_related_tag.dart';
import '../../tags/related/providers.dart';
import 'danbooru_report_data_params.dart';
import 'upload_date_range_selector_type.dart';

typedef DanbooruUserUploadParams = ({
  String username,
  int uploadCount,
});

final danbooruUserUploadsProvider =
    FutureProvider.family<List<DanbooruPost>, DanbooruUserUploadParams>(
        (ref, params) async {
  final uploadCount = params.uploadCount;
  final name = params.username;

  if (uploadCount == 0) return [];
  final config = ref.watchConfigSearch;

  final repo = ref.watch(danbooruPostRepoProvider(config));
  final uploads = await repo.getPostsFromTagsOrEmpty(
    'user:$name',
    limit: 50,
  );

  return uploads.posts;
});

final selectedUploadDateRangeSelectorTypeProvider =
    StateProvider.autoDispose<UploadDateRangeSelectorType>(
        (ref) => UploadDateRangeSelectorType.last30Days);

final userDataProvider = FutureProvider.autoDispose
    .family<List<DanbooruReportDataPoint>, DanbooruReportDataParams>(
        (ref, params) async {
  final tag = params.tag;
  final config = ref.watchConfigAuth;
  final now = DateTime.now();

  final selectedRange = ref.watch(selectedUploadDateRangeSelectorTypeProvider);
  final from = switch (selectedRange) {
    UploadDateRangeSelectorType.last7Days =>
      now.subtract(const Duration(days: 7)),
    UploadDateRangeSelectorType.last30Days =>
      now.subtract(const Duration(days: 30)),
    UploadDateRangeSelectorType.last3Months =>
      now.subtract(const Duration(days: 90)),
    UploadDateRangeSelectorType.last6Months =>
      now.subtract(const Duration(days: 180)),
    UploadDateRangeSelectorType.lastYear =>
      now.subtract(const Duration(days: 365)),
  };

  final data =
      await ref.watch(danbooruPostReportProvider(config)).getPostReports(
    tags: [
      tag,
    ],
    period: DanbooruReportPeriod.day,
    from: from,
    to: DateTime.now(),
  );

  data.sort((a, b) => a.date.compareTo(b.date));

  return data;
});

final userCopyrightDataProvider =
    FutureProvider.family<DanbooruRelatedTag, DanbooruCopyrightDataParams>(
        (ref, params) async {
  final username = params.username;
  final config = ref.watchConfigAuth;
  return ref.watch(danbooruRelatedTagRepProvider(config)).getRelatedTag(
        'user:$username',
        order: RelatedType.frequency,
        category: TagCategory.copyright(),
      );
});

typedef DanbooruCopyrightDataParams = ({
  String username,
  int uploadCount,
});
