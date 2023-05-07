// Package imports:
import 'package:equatable/equatable.dart';

enum PostQualityType {
  v180x180,
  v360x360,
  v720x720,
  sample,
  original,
}

PostQualityType mapStringToPostQualityType(String? value) {
  switch (value) {
    case '180x180':
      return PostQualityType.v180x180;
    case '360x360':
      return PostQualityType.v360x360;
    case '720x720':
      return PostQualityType.v720x720;
    case 'sample':
      return PostQualityType.sample;
    case 'original':
      return PostQualityType.original;
    default:
      return PostQualityType.sample;
  }
}

class PostVariant extends Equatable {
  const PostVariant({
    required this.type,
    required this.url,
    required this.width,
    required this.height,
    required this.fileExt,
  });

  final PostQualityType type;
  final String url;
  final int width;
  final int height;
  final String fileExt;

  @override
  List<Object?> get props => [type, url, width, height, fileExt];
}

extension PostVariantX on PostVariant {
  bool get is180x180 => type == PostQualityType.v180x180;
  bool get is360x360 => type == PostQualityType.v360x360;
  bool get is720x720 => type == PostQualityType.v720x720;
  bool get isSample => type == PostQualityType.sample;
  bool get isOriginal => type == PostQualityType.original;
}
