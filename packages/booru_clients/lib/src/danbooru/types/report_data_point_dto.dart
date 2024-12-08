class ReportDataPointDto {
  ReportDataPointDto({
    this.date,
    this.posts,
  });

  factory ReportDataPointDto.fromJson(Map<String, dynamic> json) {
    return ReportDataPointDto(
      date: json['date'],
      posts: json['posts'],
    );
  }

  final String? date;
  final int? posts;

  @override
  String toString() => '$date: $posts';
}
