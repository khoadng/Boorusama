// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/created_time.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/image_source.dart';
import 'post.dart';
import 'rating.dart';
import 'tag_string.dart';

part 'post_dto.freezed.dart';
part 'post_dto.g.dart';

@freezed
abstract class PostDto with _$PostDto {
  const factory PostDto({
    int id,
    String created_at,
    int uploader_id,
    int score,
    String source,
    String md5,
    String last_comment_bumped_at,
    String rating,
    int image_width,
    int image_height,
    String tag_string,
    bool is_note_locked,
    int fav_count,
    String file_ext,
    String last_noted_at,
    bool is_rating_locked,
    int parent_id,
    bool has_children,
    int approver_id,
    int tag_count_general,
    int tag_count_artist,
    int tag_count_character,
    int tag_count_copyright,
    int file_size,
    bool is_status_locked,
    String pool_string,
    int up_score,
    int down_score,
    bool is_pending,
    bool is_flagged,
    bool is_deleted,
    int tag_count,
    String updated_at,
    bool is_banned,
    int pixiv_id,
    String last_commented_at,
    bool has_active_children,
    int bit_flags,
    int tag_count_Meta,
    bool has_large,
    bool has_visible_children,
    String tag_string_general,
    String tag_string_character,
    String tag_string_copyright,
    String tag_string_artist,
    String tag_string_meta,
    String file_url,
    String large_file_url,
    String preview_file_url,
  }) = _PostDto;

  factory PostDto.fromJson(Map<String, dynamic> json) =>
      _$PostDtoFromJson(json);
}

extension PostDtoX on PostDto {
  Post toEntity() {
    return Post(
      id: id,
      previewImageUri: Uri.parse(preview_file_url),
      normalImageUri: Uri.parse(large_file_url),
      fullImageUri: Uri.parse(file_url),
      tagStringCopyright: tag_string_copyright,
      tagStringCharacter: tag_string_character,
      tagStringArtist: tag_string_artist,
      tagString: TagString(tag_string),
      width: image_width.toDouble(),
      height: image_height.toDouble(),
      format: file_ext,
      lastCommentAt: last_comment_bumped_at != null
          ? DateTime.parse(last_commented_at)
          : null,
      source: ImageSource(source),
      createdAt: CreatedTime(created_at),
      score: score,
      upScore: up_score,
      downScore: down_score,
      favCount: fav_count,
      uploaderId: uploader_id,
      rating: Rating(rating: rating),
    );
  }
}
