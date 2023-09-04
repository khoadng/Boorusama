// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/reports/reports.dart';
import 'package:boorusama/foundation/http/http.dart';

List<DanbooruReportDataPoint> parsePostReport(
  HttpResponse<dynamic> value,
) =>
    parseResponse(
      value: value,
      converter: (item) => DanbooruReportDataPointDto.fromJson(item),
    ).map(danbooruReportDataPointDtoToDanbooruReportDataPoint).toList();
