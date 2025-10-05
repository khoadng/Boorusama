class SourceDto {
  const SourceDto({
    required this.artist,
    required this.imageUrls,
    required this.pageUrl,
    required this.tags,
    required this.artistCommentary,
  });

  factory SourceDto.fromJson(Map<String, dynamic> json) {
    return SourceDto(
      artist: switch (json['artist']) {
        final Map<String, dynamic> map => SourceArtistDto.fromJson(map),
        _ => null,
      },
      imageUrls: switch (json['image_urls']) {
        final List<dynamic> urls => urls.whereType<String>().toList(),
        _ => null,
      },
      pageUrl: switch (json['page_url']) {
        final String url => url,
        _ => null,
      },
      tags: switch (json['tags']) {
        final List<dynamic> tagList =>
          tagList
              .whereType<List<dynamic>>()
              .map((tag) => SourceTagDto.fromJson(tag))
              .toList(),
        _ => null,
      },
      artistCommentary: switch (json['artist_commentary']) {
        final Map<String, dynamic> map => ArtistSourceCommentaryDto.fromJson(
          map,
        ),
        _ => null,
      },
    );
  }
  final SourceArtistDto? artist;
  final List<String>? imageUrls;
  final String? pageUrl;
  final List<SourceTagDto>? tags;
  final ArtistSourceCommentaryDto? artistCommentary;
}

class SourceArtistDto {
  const SourceArtistDto({
    required this.displayName,
    required this.username,
    required this.profileUrls,
    required this.artists,
  });

  factory SourceArtistDto.fromJson(Map<String, dynamic> json) {
    return SourceArtistDto(
      displayName: switch (json['display_name']) {
        final String name => name,
        _ => null,
      },
      username: switch (json['username']) {
        final String name => name,
        _ => null,
      },
      profileUrls: switch (json['profile_urls']) {
        final List<dynamic> urls => urls.whereType<String>().toList(),
        _ => null,
      },
      artists: switch (json['artists']) {
        final List<dynamic> artistList =>
          artistList
              .whereType<Map<String, dynamic>>()
              .map((artist) => SourceArtistInfoDto.fromJson(artist))
              .toList(),
        _ => null,
      },
    );
  }
  final String? displayName;
  final String? username;
  final List<String>? profileUrls;
  final List<SourceArtistInfoDto>? artists;
}

class SourceArtistInfoDto {
  const SourceArtistInfoDto({
    required this.id,
    required this.name,
  });

  factory SourceArtistInfoDto.fromJson(Map<String, dynamic> json) {
    return SourceArtistInfoDto(
      id: switch (json['id']) {
        final int id => id,
        _ => null,
      },
      name: switch (json['name']) {
        final String name => name,
        _ => null,
      },
    );
  }
  final int? id;
  final String? name;
}

class SourceTagDto {
  const SourceTagDto({
    required this.tagName,
    required this.tagUrl,
  });

  factory SourceTagDto.fromJson(List<dynamic> json) {
    return SourceTagDto(
      tagName: switch (json) {
        [final String name, ...] => name,
        [final dynamic first, ...] when first is String => first,
        _ => null,
      },
      tagUrl: switch (json) {
        [_, final String url, ...] => url,
        [_, final dynamic second, ...] when second is String => second,
        _ => null,
      },
    );
  }
  final String? tagName;
  final String? tagUrl;
}

class TagsDto {
  const TagsDto({
    required this.tagName,
    required this.tagUrl,
  });

  factory TagsDto.fromJson(List<dynamic> json) {
    return TagsDto(
      tagName: switch (json) {
        [final String name, ...] => name,
        [final dynamic first, ...] when first is String => first,
        _ => null,
      },
      tagUrl: switch (json) {
        [_, final String url, ...] => url,
        [_, final dynamic second, ...] when second is String => second,
        _ => null,
      },
    );
  }
  final String? tagName;
  final String? tagUrl;
}

class TranslatedTagsDto {
  const TranslatedTagsDto({
    required this.name,
    required this.postCount,
    required this.category,
  });

  factory TranslatedTagsDto.fromJson(Map<String, dynamic> json) {
    return TranslatedTagsDto(
      name: switch (json['name']) {
        final String name => name,
        _ => null,
      },
      postCount: switch (json['post_count']) {
        final int count => count,
        _ => null,
      },
      category: switch (json['category']) {
        final int category => category,
        _ => null,
      },
    );
  }
  final String? name;
  final int? postCount;
  final int? category;
}

class ArtistSourceCommentaryDto {
  const ArtistSourceCommentaryDto({
    required this.title,
    required this.dtextTitle,
    required this.description,
    required this.dtextDescription,
  });

  factory ArtistSourceCommentaryDto.fromJson(Map<String, dynamic> json) {
    return ArtistSourceCommentaryDto(
      title: switch (json['title']) {
        final String title => title,
        _ => null,
      },
      dtextTitle: switch (json['dtext_title']) {
        final String title => title,
        _ => null,
      },
      description: switch (json['description']) {
        final String desc => desc,
        _ => null,
      },
      dtextDescription: switch (json['dtext_description']) {
        final String desc => desc,
        _ => null,
      },
    );
  }
  final String? title;
  final String? dtextTitle;
  final String? description;
  final String? dtextDescription;
}
