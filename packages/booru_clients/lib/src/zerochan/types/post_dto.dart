class PostDto {
  PostDto({
    this.id,
    this.width,
    this.height,
    this.md5,
    this.thumbnail,
    this.source,
    this.tag,
    this.tags,
    this.full,
    this.large,
    this.medium,
    this.small,
    this.size,
    this.hash,
    this.primary,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: _readInt(json['id']),
      width: _readInt(json['width']),
      height: _readInt(json['height']),
      md5: _readString(json['md5']),
      thumbnail: _readString(json['thumbnail']),
      source: _readString(json['source']),
      tag: _readString(json['tag']),
      tags: _readStringList(json['tags']),
      full: _readString(json['full']),
      large: _readString(json['large']),
      medium: _readString(json['medium']),
      small: _readString(json['small']),
      size: _readInt(json['size']),
      hash: _readString(json['hash']),
      primary: _readString(json['primary']),
    );
  }

  final int? id;
  final int? width;
  final int? height;
  final String? md5;
  final String? thumbnail;
  final String? source;
  final String? tag;
  final List<String>? tags;
  final String? full;
  final String? large;
  final String? medium;
  final String? small;
  final int? size;
  final String? hash;
  final String? primary;

  @override
  String toString() => id.toString();
}

extension PostDtoX on PostDto {
  String? fileUrl() => _firstNonEmpty(full, _legacyFileUrl());

  String? sampleUrl() => _firstNonEmpty(large, full, _legacySampleUrl());

  String? _legacyFileUrl() => thumbnail
      ?.replaceAll(RegExp(r'/s\d+\.zerochan'), '/static.zerochan')
      .replaceAll('.240.', '.full.')
      .replaceAll('.600.', '.full.')
      .replaceAll('/240/', '/full/')
      .replaceAll('/600/', '/full/')
      ._replaceAvifExtension();

  String? _legacySampleUrl() => thumbnail
      ?.replaceAll(RegExp(r'/s\d+\.zerochan'), '/s3.zerochan')
      .replaceAll('.240.', '.600.')
      .replaceAll('/240/', '/600/')
      ._replaceAvifExtension();
}

extension on String {
  /// Zerochan only serves AVIF at thumbnail size (240px).
  /// Larger sizes (600px, full) are served as JPG.
  String _replaceAvifExtension() =>
      endsWith('.avif') ? '${substring(0, length - 5)}.jpg' : this;
}

String? _firstNonEmpty(String? first, [String? second, String? third]) {
  for (final value in [first, second, third]) {
    if (value case final value? when value.isNotEmpty) return value;
  }

  return null;
}

int? _readInt(dynamic value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  String value => int.tryParse(value),
  _ => null,
};

String? _readString(dynamic value) => value is String ? value : null;

List<String>? _readStringList(dynamic value) {
  if (value is! List) return null;

  return [
    for (final item in value)
      if (item is String) item,
  ];
}
