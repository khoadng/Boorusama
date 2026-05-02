// Project imports:
import 'json_parsing.dart';
import 'types.dart';

class PostsDto {
  const PostsDto({
    required this.posts,
    this.postsPerPage,
    this.responsePostsCount,
    this.pageNumber,
    this.postsCount,
    this.maxPages,
  });

  factory PostsDto.fromJson(Map<String, dynamic> json, String baseUrl) {
    return PostsDto(
      posts:
          listFromJson(
            json['posts'],
            (item) => PostDto.fromJson(item, baseUrl),
          ) ??
          const [],
      postsPerPage: intFromJson(json['posts_per_page']),
      responsePostsCount: intFromJson(json['response_posts_count']),
      pageNumber: intFromJson(json['page_number']),
      postsCount: intFromJson(json['posts_count']),
      maxPages: intFromJson(json['max_pages']),
    );
  }

  final List<PostDto> posts;
  final int? postsPerPage;
  final int? responsePostsCount;
  final int? pageNumber;
  final int? postsCount;
  final int? maxPages;
}

class PostDto {
  const PostDto({
    this.id,
    this.md5,
    this.md5Pixels,
    this.juserId,
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
    final md5 = stringFromJson(json['md5']);
    final extRaw = stringFromJson(json['ext']);
    final haveAlpha = boolFromJson(json['have_alpha']);

    final small =
        stringFromJson(json['small_preview']) ??
        createUrl(
          baseUrl,
          md5,
          ImageUrlType.small,
          extRaw,
          haveAlpha,
        );

    final medium =
        stringFromJson(json['medium_preview']) ??
        createUrl(
          baseUrl,
          md5,
          ImageUrlType.medium,
          extRaw,
          haveAlpha,
        );

    final big =
        stringFromJson(json['big_preview']) ??
        createUrl(
          baseUrl,
          md5,
          ImageUrlType.big,
          extRaw,
          haveAlpha,
        );

    return PostDto(
      id: intFromJson(json['id']),
      md5: md5,
      md5Pixels: stringFromJson(json['md5_pixels']),
      juserId: intFromJson(json['juser_id']),
      width: intFromJson(json['width']),
      height: intFromJson(json['height']),
      pubtime: stringFromJson(json['pubtime']),
      datetime: stringFromJson(json['datetime']),
      score: doubleFromJson(json['score']),
      scoreNumber: intFromJson(json['score_number']),
      size: intFromJson(json['size']),
      downloadCount: intFromJson(json['download_count']),
      erotics: switch (intFromJson(json['erotics'])) {
        0 => EroticLevel.none,
        1 => EroticLevel.light,
        2 => EroticLevel.moderate,
        3 => EroticLevel.hard,
        _ => null,
      },
      color: switch (json['color']) {
        final List color => color.map(intFromJson).whereType<int>().toList(),
        _ => null,
      },
      ext: extRaw,
      status: intFromJson(json['status']),
      statusType: intFromJson(json['status_type']),
      redirectId: intFromJson(json['redirect_id']),
      spoiler: boolFromJson(json['spoiler']),
      haveAlpha: haveAlpha,
      tagsCount: intFromJson(json['tags_count']),
      artefactsDegree: doubleFromJson(json['artefacts_degree']),
      smoothDegree: doubleFromJson(json['smooth_degree']),
      smallPreview: small,
      mediumPreview: medium,
      bigPreview: big,
    );
  }

  final int? id;
  final String? md5;
  final String? md5Pixels;
  final int? juserId;
  final int? width;
  final int? height;
  final String? pubtime;
  final String? datetime;
  final double? score;
  final int? scoreNumber;
  final int? size;
  final int? downloadCount;
  final EroticLevel? erotics;
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
}

enum TopLength {
  day,
  week,
}

enum EroticLevel {
  none,
  light,
  moderate,
  hard,
}

enum PostOrder {
  starsDate,
}

class PostDetailsTagDto {
  const PostDetailsTagDto({
    required this.tag,
    required this.user,
  });

  factory PostDetailsTagDto.fromJson(Map<String, dynamic> json) {
    return PostDetailsTagDto(
      tag: switch (mapFromJson(json['tag'])) {
        final tag? => TagDto.fromJson(tag),
        _ => null,
      },
      user: switch (mapFromJson(json['user'])) {
        final user? => UserDto.fromJson(user),
        _ => null,
      },
    );
  }

  final TagDto? tag;
  final UserDto? user;
}

class PostDetailsFavoritesUserDto {
  const PostDetailsFavoritesUserDto({
    required this.user,
    required this.favorite,
  });

  factory PostDetailsFavoritesUserDto.fromJson(Map<String, dynamic> json) {
    return PostDetailsFavoritesUserDto(
      user: switch (mapFromJson(json['user'])) {
        final user? => UserDto.fromJson(user),
        _ => null,
      },
      favorite: switch (mapFromJson(json['favorite'])) {
        final favorite? => FavoriteDto.fromJson(favorite),
        _ => null,
      },
    );
  }

  final UserDto? user;
  final FavoriteDto? favorite;
}

class PostDetailsDto {
  const PostDetailsDto({
    required this.post,
    required this.user,
    required this.moderator,
    required this.tags,
    required this.starIt,
    required this.favoritesUsers,
    required this.fileUrl,
    required this.tied,
  });

  factory PostDetailsDto.fromJson(Map<String, dynamic> json, String baseUrl) {
    return PostDetailsDto(
      post: switch (mapFromJson(json['post'])) {
        final post? => PostDto.fromJson(post, baseUrl),
        _ => null,
      },
      user: switch (mapFromJson(json['user'])) {
        final user? => UserDto.fromJson(user),
        _ => null,
      },
      moderator: switch (mapFromJson(json['moderator'])) {
        final moderator? => UserDto.fromJson(moderator),
        _ => null,
      },
      tags: listFromJson(json['tags'], PostDetailsTagDto.fromJson),
      starIt: boolFromJson(json['star_it']) ?? false,
      favoritesUsers: listFromJson(
        json['favorites_users'],
        PostDetailsFavoritesUserDto.fromJson,
      ),
      fileUrl: stringFromJson(json['file_url']),
      tied: listFromJson(
        json['tied'],
        (item) => PostDto.fromJson(item, baseUrl),
      ),
    );
  }

  final PostDto? post;
  final UserDto? user;
  final UserDto? moderator;
  final List<PostDetailsTagDto>? tags;
  final bool starIt;
  final List<PostDetailsFavoritesUserDto>? favoritesUsers;
  final String? fileUrl;
  final List<PostDto>? tied;
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
    ImageUrlType.original => baseUrl.replaceFirst(
      'https://api.',
      'https://oimages.',
    ),
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
    _ => '.avif',
  };

  return '$url$first3/$md5$qualityQualifier$ext';
}

enum ImageUrlType {
  small,
  medium,
  big,
  original,
}
