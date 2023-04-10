class PostDto {
  PostDto({
    required this.id,
    required this.createdAt,
    required this.score,
    required this.width,
    required this.height,
    required this.md5,
    required this.directory,
    required this.image,
    required this.rating,
    required this.source,
    required this.change,
    required this.owner,
    required this.creatorId,
    required this.parentId,
    required this.sample,
    required this.previewHeight,
    required this.previewWidth,
    required this.tags,
    required this.title,
    required this.hasNotes,
    required this.hasComments,
    required this.fileUrl,
    required this.previewUrl,
    required this.sampleUrl,
    required this.sampleHeight,
    required this.sampleWidth,
    required this.status,
    required this.postLocked,
    required this.hasChildren,
  });
  factory PostDto.fromJson(Map<String, dynamic> json) => PostDto(
        id: json['id'],
        createdAt: json['created_at'],
        score: json['score'],
        width: json['width'],
        height: json['height'],
        md5: json['md5'],
        directory: json['directory'],
        image: json['image'],
        rating: json['rating'],
        source: json['source'],
        change: json['change'],
        owner: json['owner'],
        creatorId: json['creator_id'],
        parentId: json['parent_id'],
        sample: json['sample'],
        previewHeight: json['preview_height'],
        previewWidth: json['preview_width'],
        tags: json['tags'],
        title: json['title'],
        hasNotes: json['has_notes'],
        hasComments: json['has_comments'],
        fileUrl: json['file_url'],
        previewUrl: json['preview_url'],
        sampleUrl: json['sample_url'],
        sampleHeight: json['sample_height'],
        sampleWidth: json['sample_width'],
        status: json['status'],
        postLocked: json['post_locked'],
        hasChildren: json['has_children'],
      );

  final int? id;
  final String? createdAt;
  final int? score;
  final int? width;
  final int? height;
  final String? md5;
  final String? directory;
  final String? image;
  final String? rating;
  final String? source;
  final int? change;
  final String? owner;
  final int? creatorId;
  final int? parentId;
  final int? sample;
  final int? previewHeight;
  final int? previewWidth;
  final String? tags;
  final String? title;
  final String? hasNotes;
  final String? hasComments;
  final String? fileUrl;
  final String? previewUrl;
  final String? sampleUrl;
  final int? sampleHeight;
  final int? sampleWidth;
  final String? status;
  final int? postLocked;
  final String? hasChildren;
}
