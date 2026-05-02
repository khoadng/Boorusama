import 'media_dto.dart';
import 'tag_dto.dart';

class NozomiPostDto {
  const NozomiPostDto({
    required this.id,
    required this.dataId,
    required this.type,
    required this.imageUrls,
    required this.generalTags,
    required this.artistTags,
    required this.copyrightTags,
    required this.characterTags,
    this.width,
    this.height,
    this.isVideo = false,
    this.date,
  });

  factory NozomiPostDto.fromJson(Map<dynamic, dynamic> json) {
    return NozomiPostDto(
      id: json['postid'] as int? ?? 0,
      dataId: json['dataid']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      isVideo: _parseBool(json['is_video']),
      date: json['date']?.toString(),
      imageUrls: _parseMedia(json['imageurls']),
      generalTags: _parseTags(json['general']),
      artistTags: _parseTags(json['artist']),
      copyrightTags: _parseTags(json['copyright']),
      characterTags: _parseTags(json['character']),
    );
  }

  final int id;
  final String dataId;
  final String type;
  final int? width;
  final int? height;
  final bool isVideo;
  final String? date;
  final List<NozomiMediaDto> imageUrls;
  final List<NozomiTagDto> generalTags;
  final List<NozomiTagDto> artistTags;
  final List<NozomiTagDto> copyrightTags;
  final List<NozomiTagDto> characterTags;

  NozomiMediaDto? get primaryMedia {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    if (dataId.isEmpty) return null;

    return NozomiMediaDto(
      dataId: dataId,
      type: type,
      isVideo: isVideo,
      width: width,
      height: height,
    );
  }

  Set<String> get allTags => {
    ...generalTags.map((e) => e.tag),
    ...artistTags.map((e) => e.tag),
    ...copyrightTags.map((e) => e.tag),
    ...characterTags.map((e) => e.tag),
  }..remove('');
}

List<NozomiMediaDto> _parseMedia(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map(NozomiMediaDto.fromJson)
      .where((e) => e.dataId.isNotEmpty)
      .toList();
}

List<NozomiTagDto> _parseTags(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map(NozomiTagDto.fromJson)
      .where((e) => e.tag.isNotEmpty)
      .toList();
}

bool _parseBool(dynamic value) => switch (value) {
  final bool b => b,
  final num n => n != 0,
  final String s => s.isNotEmpty && s != '0' && s != 'false',
  _ => false,
};
