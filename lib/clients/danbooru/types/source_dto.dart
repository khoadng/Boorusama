// Project imports:
import 'package:boorusama/clients/danbooru/types/artist_dto.dart' as d;

class SourceDto {
  final ArtistDto? artist;
  final List<d.ArtistDto>? artists;
  final List<ImageUrlsDto>? imageUrls;
  final String? pageUrl;
  final List<TagsDto>? tags;
  final List<String>? normalizedTags;
  final List<TranslatedTagsDto>? translatedTags;
  final ArtistCommentaryDto? artistCommentary;

  const SourceDto({
    required this.artist,
    required this.artists,
    required this.imageUrls,
    required this.pageUrl,
    required this.tags,
    required this.normalizedTags,
    required this.translatedTags,
    required this.artistCommentary,
  });

  factory SourceDto.fromJson(Map<String, dynamic> json) {
    return SourceDto(
      artist:
          json['artist'] != null ? ArtistDto.fromJson(json['artist']) : null,
      artists: (json['artists'] as List<dynamic>?)
          ?.map((artist) => d.ArtistDto.fromJson(artist))
          .toList(),
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((imageUrl) => ImageUrlsDto.fromJson(imageUrl))
          .toList(),
      pageUrl: json['page_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => TagsDto.fromJson(tag))
          .toList(),
      normalizedTags: (json['normalized_tags'] as List<dynamic>?)
          ?.map((tag) => tag as String)
          .toList(),
      translatedTags: (json['translated_tags'] as List<dynamic>?)
          ?.map((translatedTag) => TranslatedTagsDto.fromJson(translatedTag))
          .toList(),
      artistCommentary: json['artist_commentary'] != null
          ? ArtistCommentaryDto.fromJson(json['artist_commentary'])
          : null,
    );
  }
}

class ArtistDto {
  final String? name;
  final String? tagName;
  final List<String>? otherNames;
  final String? profileUrl;
  final List<String>? profileUrls;

  const ArtistDto({
    required this.name,
    required this.tagName,
    required this.otherNames,
    required this.profileUrl,
    required this.profileUrls,
  });

  factory ArtistDto.fromJson(Map<String, dynamic> json) {
    return ArtistDto(
      name: json['name'] as String?,
      tagName: json['tag_name'] as String?,
      otherNames: (json['other_names'] as List<dynamic>?)
          ?.map((name) => name as String)
          .toList(),
      profileUrl: json['profile_url'] as String?,
      profileUrls: (json['profile_urls'] as List<dynamic>?)
          ?.map((url) => url as String)
          .toList(),
    );
  }
}

class ImageUrlsDto {
  final String? imageUrl;

  const ImageUrlsDto({
    required this.imageUrl,
  });

  factory ImageUrlsDto.fromJson(String json) {
    return ImageUrlsDto(
      imageUrl: json,
    );
  }
}

class TagsDto {
  final String? tagName;
  final String? tagUrl;

  const TagsDto({
    required this.tagName,
    required this.tagUrl,
  });

  factory TagsDto.fromJson(List<dynamic> json) {
    return TagsDto(
      tagName: json.isNotEmpty ? json[0] as String? : null,
      tagUrl: json.length > 1 ? json[1] as String? : null,
    );
  }
}

class TranslatedTagsDto {
  final String? name;
  final int? postCount;
  final int? category;

  const TranslatedTagsDto({
    required this.name,
    required this.postCount,
    required this.category,
  });

  factory TranslatedTagsDto.fromJson(Map<String, dynamic> json) {
    return TranslatedTagsDto(
      name: json['name'] as String?,
      postCount: json['post_count'] as int?,
      category: json['category'] as int?,
    );
  }
}

class ArtistCommentaryDto {
  final String? title;
  final String? dtextTitle;
  final String? description;
  final String? dtextDescription;

  const ArtistCommentaryDto({
    required this.title,
    required this.dtextTitle,
    required this.description,
    required this.dtextDescription,
  });

  factory ArtistCommentaryDto.fromJson(Map<String, dynamic> json) {
    return ArtistCommentaryDto(
      title: json['title'] as String?,
      dtextTitle: json['dtext_title'] as String?,
      description: json['description'] as String?,
      dtextDescription: json['dtext_description'] as String?,
    );
  }
}
