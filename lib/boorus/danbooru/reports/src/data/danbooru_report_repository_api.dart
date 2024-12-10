// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_report_data_point.dart';
import '../types/danbooru_report_period.dart';
import '../types/danbooru_report_repository.dart';
import 'converter.dart';

class DanbooruReportRepositoryApi implements DanbooruReportRepository {
  DanbooruReportRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<DanbooruReportDataPoint>> getPostReports({
    required List<String> tags,
    required DanbooruReportPeriod period,
    required DateTime from,
    required DateTime to,
  }) =>
      client
          .getPostReport(
            tags: tags,
            period: switch (period) {
              DanbooruReportPeriod.day => ReportPeriod.day,
              DanbooruReportPeriod.week => ReportPeriod.week,
              DanbooruReportPeriod.month => ReportPeriod.month,
              DanbooruReportPeriod.year => ReportPeriod.year,
            },
            from: from,
            to: to,
          )
          .then((value) => value
              .map(danbooruReportDataPointDtoToDanbooruReportDataPoint)
              .toList());
}
