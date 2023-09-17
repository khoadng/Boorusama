// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';

class DanbooruReportDataPoint extends Equatable {
  const DanbooruReportDataPoint({
    required this.date,
    required this.postCount,
  });

  final DateTime date;
  final int postCount;

  DanbooruReportDataPoint copyWith({
    DateTime? date,
    int? postCount,
  }) {
    return DanbooruReportDataPoint(
      date: date ?? this.date,
      postCount: postCount ?? this.postCount,
    );
  }

  @override
  List<Object?> get props => [date, postCount];
}

DanbooruReportDataPoint danbooruReportDataPointDtoToDanbooruReportDataPoint(
  ReportDataPointDto dto,
) {
  return DanbooruReportDataPoint(
    date: dto.date != null ? DateTime.parse(dto.date!) : DateTime.now(),
    postCount: dto.posts ?? 0,
  );
}
