class PostDto {
  final int? id;
  final String? md5;
  final String? md5Pixels;
  final int? width;
  final int? height;
  final String? pubtime;
  final String? datetime;
  final int? score;
  final int? scoreNumber;
  final int? size;
  final int? downloadCount;
  final int? erotics;
  final List<int>? color;
  final String? ext;
  final int? status;
  final int? statusType;
  final int? redirectId;
  final bool? spoiler;
  final bool? haveAlpha;
  final int? tagsCount;
  final double? artefactsDegree;
  final double? smoothDegree;

  final String? smallPreview;
  final String? mediumPreview;
  final String? bigPreview;

  PostDto({
    this.id,
    this.md5,
    this.md5Pixels,
    this.width,
    this.height,
    this.pubtime,
    this.datetime,
    this.score,
    this.scoreNumber,
    this.size,
    this.downloadCount,
    this.erotics,
    this.color,
    this.ext,
    this.status,
    this.statusType,
    this.redirectId,
    this.spoiler,
    this.haveAlpha,
    this.tagsCount,
    this.artefactsDegree,
    this.smoothDegree,
    this.smallPreview,
    this.mediumPreview,
    this.bigPreview,
  });

  factory PostDto.fromJson(Map<String, dynamic> json, String baseUrl) {
    final extRaw = json['ext'];
    final haveAlpha = json['have_alpha'];

    final small = json['small_preview'] ??
        createUrl(
          baseUrl,
          json['md5'],
          ImageUrlType.small,
          extRaw,
          haveAlpha,
        );

    final medium = json['medium_preview'] ??
        createUrl(
          baseUrl,
          json['md5'],
          ImageUrlType.medium,
          extRaw,
          haveAlpha,
        );

    final big = json['big_preview'] ??
        createUrl(
          baseUrl,
          json['md5'],
          ImageUrlType.big,
          extRaw,
          haveAlpha,
        );

    return PostDto(
      id: json['id'],
      md5: json['md5'],
      md5Pixels: json['md5_pixels'],
      width: json['width'],
      height: json['height'],
      pubtime: json['pubtime'],
      datetime: json['datetime'],
      score: json['score'],
      scoreNumber: json['score_number'],
      size: json['size'],
      downloadCount: json['download_count'],
      erotics: json['erotics'],
      color: json['color']?.cast<int>(),
      ext: json['ext'],
      status: json['status'],
      statusType: json['status_type'],
      redirectId: json['redirect_id'],
      spoiler: json['spoiler'],
      haveAlpha: haveAlpha,
      tagsCount: json['tags_count'],
      artefactsDegree: json['artefacts_degree'],
      smoothDegree: json['smooth_degree'],
      smallPreview: small,
      mediumPreview: medium,
      bigPreview: big,
    );
  }
}

class PostDetailsDto {
  PostDetailsDto({
    required this.post,
    required this.fileUrl,
  });

  final PostDto? post;
  final String? fileUrl;

  factory PostDetailsDto.fromJson(Map<String, dynamic> json, String baseUrl) {
    final post =
        json['post'] != null ? PostDto.fromJson(json['post'], baseUrl) : null;
    final fileUrl = json['file_url'];

    return PostDetailsDto(
      post: post,
      fileUrl: fileUrl,
    );
  }
}

String? createUrl(
  String baseUrl,
  String? md5,
  ImageUrlType type,
  String? extRaw,
  bool? haveAlpha,
) {
  if (md5 == null) return null;
  if (extRaw == null) return null;
  if (haveAlpha == null) return null;

  final url = switch (type) {
    ImageUrlType.original =>
      baseUrl.replaceFirst('https://api.', 'https://oimages.'),
    _ => baseUrl.replaceFirst('https://api.', 'https://opreviews.'),
  };

  // extract the first 3 characters of the md5 hash
  final first3 = md5.substring(0, 3);
  final qualityQualifier = switch (type) {
    ImageUrlType.small => '_sp',
    ImageUrlType.medium => '_cp',
    ImageUrlType.big => '_bp',
    ImageUrlType.original => '',
  };

  final ext = switch (type) {
    ImageUrlType.original => extRaw,
    _ => switch (extRaw) {
        '.gif' => '.gif',
        _ => haveAlpha ? '.png' : '.jpg',
      }
  };

  return '$url$first3/$md5$qualityQualifier$ext';
}

enum ImageUrlType {
  small,
  medium,
  big,
  original,
}
