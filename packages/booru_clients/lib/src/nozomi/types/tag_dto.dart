class NozomiTagDto {
  const NozomiTagDto({
    required this.tag,
    required this.displayName,
    required this.type,
  });

  factory NozomiTagDto.fromJson(Map<dynamic, dynamic> json) {
    final tag = json['tag']?.toString() ?? '';

    return NozomiTagDto(
      tag: tag,
      displayName: json['tagname_display']?.toString() ?? tag,
      type: json['tagtype']?.toString() ?? 'general',
    );
  }

  final String tag;
  final String displayName;
  final String type;
}
