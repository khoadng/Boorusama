// Package imports:
import 'package:xml/xml.dart';

// Project imports:
import 'comment_dto.dart';
import 'numeric_score_vote_dto.dart';

class PostDto {
  PostDto({
    this.id,
    this.md5,
    this.fileName,
    this.fileUrl,
    this.height,
    this.width,
    this.previewUrl,
    this.previewHeight,
    this.previewWidth,
    this.rating,
    this.date,
    this.tags,
    this.source,
    this.score,
    this.author,
    this.filesize,
    this.locked,
    this.ext,
    this.mime,
    this.niceName,
    this.tooltip,
    this.favorites,
    this.numericScore,
    this.notes,
    this.parentId,
    this.hasChildren,
    this.title,
    this.approved,
    this.approvedById,
    this.private,
    this.trash,
    this.ownerName,
    this.ownerJoinDate,
    this.votes,
    this.myVote,
    this.comments,
  });

  factory PostDto.fromXml(
    XmlElement xml, {
    String? baseUrl,
  }) {
    final previewUrl = xml.getAttribute('preview_url');
    final fileUrl = xml.getAttribute('file_url');

    return PostDto(
      id: int.tryParse(xml.getAttribute('id') ?? ''),
      md5: xml.getAttribute('md5'),
      fileName: xml.getAttribute('file_name'),
      fileUrl: _resolveUrl(fileUrl, baseUrl),
      height: int.tryParse(xml.getAttribute('height') ?? ''),
      width: int.tryParse(xml.getAttribute('width') ?? ''),
      previewUrl: _resolveUrl(previewUrl, baseUrl),
      previewHeight: int.tryParse(xml.getAttribute('preview_height') ?? ''),
      previewWidth: int.tryParse(xml.getAttribute('preview_width') ?? ''),
      rating: xml.getAttribute('rating'),
      date: DateTime.tryParse(xml.getAttribute('date') ?? ''),
      tags: xml.getAttribute('tags')?.split(' '),
      source: xml.getAttribute('source'),
      score: int.tryParse(xml.getAttribute('score') ?? ''),
      author: xml.getAttribute('author'),
    );
  }

  factory PostDto.fromGraphQL(
    Map<String, dynamic> json, {
    String? baseUrl,
  }) {
    final owner = switch (json['owner']) {
      final Map<String, dynamic> o => o,
      _ => null,
    };
    final tags = switch (json['tags']) {
      final List t => t,
      _ => null,
    };

    return PostDto(
      id: switch (json['post_id']) {
        final num n => n.toInt(),
        _ => null,
      },
      md5: switch (json['hash']) {
        final String s => s,
        _ => null,
      },
      fileName: switch (json['filename']) {
        final String s => s,
        _ => null,
      },
      fileUrl: _resolveUrl(json['image_link'] as String?, baseUrl),
      height: switch (json['height']) {
        final num n => n.toInt(),
        _ => null,
      },
      width: switch (json['width']) {
        final num n => n.toInt(),
        _ => null,
      },
      previewUrl: _resolveUrl(json['thumb_link'] as String?, baseUrl),
      date: switch (json['posted']) {
        null => null,
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      tags: tags?.map((e) => e.toString()).toList(),
      source: switch (json['source']) {
        final String s => s,
        _ => null,
      },
      filesize: switch (json['filesize']) {
        final num n => n.toInt(),
        _ => null,
      },
      locked: switch (json['locked']) {
        final bool b => b,
        _ => null,
      },
      ext: switch (json['ext']) {
        final String s => s,
        _ => null,
      },
      mime: switch (json['mime']) {
        final String s => s,
        _ => null,
      },
      niceName: switch (json['nice_name']) {
        final String s => s,
        _ => null,
      },
      tooltip: switch (json['tooltip']) {
        final String s => s,
        _ => null,
      },
      ownerName: switch (owner?['name']) {
        final String s => s,
        _ => null,
      },
      ownerJoinDate: switch (owner?['join_date']) {
        final String jd => DateTime.tryParse(jd),
        _ => null,
      },
      // Extension fields
      score: switch (json['score']) {
        final num n => n.toInt(),
        _ => null,
      },
      votes: switch (json['votes']) {
        final List l =>
          l
              .whereType<Map<String, dynamic>>()
              .map((e) => NumericScoreVoteDto.fromGraphQL(e))
              .toList(),
        _ => null,
      },
      myVote: switch (json['my_vote']) {
        final num n => n.toInt(),
        _ => null,
      },
      favorites: switch (json['favorites']) {
        final num n => n.toInt(),
        _ => null,
      },
      numericScore: switch (json['numeric_score']) {
        final num n => n.toInt(),
        _ => null,
      },
      rating: switch (json['rating']) {
        final String s => s,
        _ => null,
      },
      notes: switch (json['notes']) {
        final num n => n.toInt(),
        _ => null,
      },
      parentId: switch (json['parent_id']) {
        final num n => n.toInt(),
        _ => null,
      },
      hasChildren: switch (json['has_children']) {
        final bool b => b,
        _ => null,
      },
      author: switch (json['author']) {
        final String s => s,
        _ => null,
      },
      title: switch (json['title']) {
        final String s => s,
        _ => null,
      },
      approved: switch (json['approved']) {
        final bool b => b,
        _ => null,
      },
      approvedById: switch (json['approved_by_id']) {
        final num n => n.toInt(),
        _ => null,
      },
      private: switch (json['private']) {
        final bool b => b,
        _ => null,
      },
      trash: switch (json['trash']) {
        final bool b => b,
        _ => null,
      },
      comments: switch (json['comments']) {
        final List l =>
          l
              .whereType<Map<String, dynamic>>()
              .map((e) => CommentDto.fromGraphQL(e))
              .toList(),
        _ => null,
      },
    );
  }

  final int? id;
  final String? md5;
  final String? fileName;
  final String? fileUrl;
  final int? height;
  final int? width;
  final String? previewUrl;
  final int? previewHeight;
  final int? previewWidth;
  final String? rating;
  final DateTime? date;
  final List<String>? tags;
  final String? source;
  final int? score;
  final String? author;

  // GraphQL-specific fields
  final int? filesize;
  final bool? locked;
  final String? ext;
  final String? mime;
  final String? niceName;
  final String? tooltip;
  final int? favorites;
  final int? numericScore;
  final int? notes;
  final int? parentId;
  final bool? hasChildren;
  final String? title;
  final bool? approved;
  final int? approvedById;
  final bool? private;
  final bool? trash;
  final String? ownerName;
  final DateTime? ownerJoinDate;
  final List<NumericScoreVoteDto>? votes;
  final int? myVote;
  final List<CommentDto>? comments;

  @override
  String toString() => '$id: $fileUrl';
}

String? _resolveUrl(String? url, String? baseUrl) => switch ((url, baseUrl)) {
  (final url?, _) when url.startsWith('http') => url,
  (final url?, final base?) => Uri.tryParse(base)?.resolve(url).toString(),
  _ => null,
};
