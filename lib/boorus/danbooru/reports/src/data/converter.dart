// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_report_data_point.dart';

DanbooruReportDataPoint danbooruReportDataPointDtoToDanbooruReportDataPoint(
  ReportDataPointDto dto,
) {
  return DanbooruReportDataPoint(
    date: dto.date != null ? DateTime.parse(dto.date!) : DateTime.now(),
    postCount: dto.posts ?? 0,
  );
}
