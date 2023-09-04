// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/time.dart';
import 'danbooru_report_data_point.dart';
import 'danbooru_report_parser.dart';
import 'types.dart';

abstract class DanbooruReportRepository {
  Future<List<DanbooruReportDataPoint>> getPostReports({
    required List<String> tags,
    required DanbooruReportPeriod period,
    required DateTime from,
    required DateTime to,
  });
}

class DanbooruReportRepositoryApi implements DanbooruReportRepository {
  DanbooruReportRepositoryApi({
    required this.danbooruApi,
  });

  final DanbooruApi danbooruApi;

  @override
  Future<List<DanbooruReportDataPoint>> getPostReports({
    required List<String> tags,
    required DanbooruReportPeriod period,
    required DateTime from,
    required DateTime to,
  }) =>
      danbooruApi
          .getPostReport(
            tags.join(' '),
            period.name,
            from.yyyyMMddWithHyphen(),
            to.yyyyMMddWithHyphen(),
          )
          .then(parsePostReport);
}
