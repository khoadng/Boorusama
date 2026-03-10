class CommentDto {
  CommentDto({
    this.postId,
    this.postText,
    this.postTextHtml,
    this.imageId,
    this.parentCommentId,
    this.deleted,
    this.userId,
    this.date,
    this.updateCount,
    this.lastUpdated,
    this.lastUpdatedUserId,
    this.username,
    this.userAvatarUrl,
    this.userTitle,
    this.userGroups,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final user = switch (json['user']) {
      final Map<String, dynamic> u => u,
      _ => null,
    };

    return CommentDto(
      postId: switch (json['post_id']) {
        final int v => v,
        _ => null,
      },
      postText: switch (json['post_text']) {
        final String v => v,
        _ => null,
      },
      postTextHtml: switch (json['post_text_html']) {
        final String v => v,
        _ => null,
      },
      imageId: switch (json['image_id']) {
        final int v => v,
        _ => null,
      },
      parentCommentId: switch (json['parent_comment_id']) {
        final int v => v,
        _ => null,
      },
      deleted: switch (json['deleted']) {
        final bool v => v,
        _ => null,
      },
      userId: switch (json['user_id']) {
        final int v => v,
        _ => null,
      },
      date: switch (json['date']) {
        final String v => DateTime.tryParse(v),
        _ => null,
      },
      updateCount: switch (json['update_count']) {
        final int v => v,
        _ => null,
      },
      lastUpdated: switch (json['last_updated']) {
        final String v => DateTime.tryParse(v),
        _ => null,
      },
      lastUpdatedUserId: switch (json['last_updated_user_id']) {
        final int v => v,
        _ => null,
      },
      username: switch (user?['username']) {
        final String v => v,
        _ => null,
      },
      userAvatarUrl: switch (user?['avatar_url']) {
        final String v => v,
        _ => null,
      },
      userTitle: switch (user?['user_title']) {
        final String v => v,
        _ => null,
      },
      userGroups: switch (user?['groups']) {
        final List list => list.whereType<String>().toList(),
        _ => null,
      },
    );
  }

  final int? postId;
  final String? postText;
  final String? postTextHtml;
  final int? imageId;
  final int? parentCommentId;
  final bool? deleted;
  final int? userId;
  final DateTime? date;
  final int? updateCount;
  final DateTime? lastUpdated;
  final int? lastUpdatedUserId;
  final String? username;
  final String? userAvatarUrl;
  final String? userTitle;
  final List<String>? userGroups;
}
