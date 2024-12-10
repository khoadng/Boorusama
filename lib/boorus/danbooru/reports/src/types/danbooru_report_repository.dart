// Package imports:

// Project imports:
import 'danbooru_report_data_point.dart';
import 'danbooru_report_period.dart';

abstract class DanbooruReportRepository {
  Future<List<DanbooruReportDataPoint>> getPostReports({
    required List<String> tags,
    required DanbooruReportPeriod period,
    required DateTime from,
    required DateTime to,
  });
}
