class TagSummaryDto {
  final int? version;
  final String? data;

  TagSummaryDto({this.version, this.data});

  factory TagSummaryDto.fromJson(Map<String, dynamic> json) {
    return TagSummaryDto(
      version: json['version'],
      data: json['data'],
    );
  }
}
