class NozomiMediaDto {
  const NozomiMediaDto({
    required this.dataId,
    required this.type,
    required this.isVideo,
    this.width,
    this.height,
  });

  factory NozomiMediaDto.fromJson(Map<dynamic, dynamic> json) {
    return NozomiMediaDto(
      dataId: json['dataid']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isVideo: _parseBool(json['is_video']),
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  final String dataId;
  final String type;
  final bool isVideo;
  final int? width;
  final int? height;

  String get mediaUrl {
    final ext = isVideo
        ? type
        : switch (type) {
            'gif' => 'gif',
            _ => 'webp',
          };
    final subdomain = isVideo
        ? 'v'
        : switch (type) {
            'gif' => 'g',
            _ => 'w',
          };

    return 'https://$subdomain.gold-usergeneratedcontent.net'
        '/${NozomiPath.dataPath(dataId)}.$ext';
  }

  String get thumbnailUrl {
    return 'https://qtn.gold-usergeneratedcontent.net'
        '/${NozomiPath.dataPath(dataId)}.$type.webp';
  }
}

class NozomiPath {
  const NozomiPath._();

  static String dataPath(Object id) {
    final value = id.toString();

    if (value.length < 3) return value;

    final last = value.substring(value.length - 1);
    final previousTwo = value.substring(value.length - 3, value.length - 1);

    return '$last/$previousTwo/$value';
  }
}

bool _parseBool(dynamic value) => switch (value) {
  final bool b => b,
  final num n => n != 0,
  final String s => s.isNotEmpty && s != '0' && s != 'false',
  _ => false,
};
