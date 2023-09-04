// Package imports:
import 'package:equatable/equatable.dart';

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

class DanbooruReportDataPointDto {
  final String? date;
  final int? posts;

  DanbooruReportDataPointDto({
    this.date,
    this.posts,
  });

  factory DanbooruReportDataPointDto.fromJson(Map<String, dynamic> json) {
    return DanbooruReportDataPointDto(
      date: json['date'],
      posts: json['posts'],
    );
  }
}

DanbooruReportDataPoint danbooruReportDataPointDtoToDanbooruReportDataPoint(
  DanbooruReportDataPointDto dto,
) {
  return DanbooruReportDataPoint(
    date: dto.date != null ? DateTime.parse(dto.date!) : DateTime.now(),
    postCount: dto.posts ?? 0,
  );
}
