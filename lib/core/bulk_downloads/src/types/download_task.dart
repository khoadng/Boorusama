// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../search/selected_tags/tag.dart';

class DownloadTask extends Equatable {
  const DownloadTask({
    required this.id,
    required this.path,
    required this.notifications,
    required this.skipIfExists,
    required this.createdAt,
    required this.updatedAt,
    required this.perPage,
    required this.concurrency,
    this.quality,
    this.tags,
    this.blacklistedTags,
  });

  factory DownloadTask.empty() {
    return DownloadTask(
      id: '',
      path: '',
      notifications: true,
      skipIfExists: true,
      createdAt: DateTime(1),
      updatedAt: DateTime(1),
      perPage: 20,
      concurrency: 1,
    );
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json) => DownloadTask(
    id: json['id'] as String? ?? '',
    path: json['path'] as String? ?? '',
    notifications: json['notifications'] as bool? ?? false,
    skipIfExists: json['skipIfExists'] as bool? ?? false,
    quality: json['quality'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
    perPage: json['perPage'] as int? ?? 20,
    concurrency: json['concurrency'] as int? ?? 1,
    tags: json['tags'] as String?,
    blacklistedTags: json['blacklistedTags'] as String?,
  );

  final String id;
  final String path;
  final bool notifications;
  final bool skipIfExists;
  final String? quality;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int perPage;
  final int concurrency;
  final String? tags;
  final String? blacklistedTags;

  String? get prettyTags => tags == null
      ? null
      : SearchTagSet.fromString(tags).spaceDelimitedOriginalTags;

  DownloadTask copyWith({
    String? path,
    bool? notifications,
    bool? skipIfExists,
    String? quality,
    int? perPage,
    int? concurrency,
    String? tags,
    String? blacklistedTags,
  }) => DownloadTask(
    id: id,
    path: path ?? this.path,
    notifications: notifications ?? this.notifications,
    skipIfExists: skipIfExists ?? this.skipIfExists,
    quality: quality ?? this.quality,
    createdAt: createdAt,
    updatedAt: updatedAt,
    perPage: perPage ?? this.perPage,
    concurrency: concurrency ?? this.concurrency,
    tags: tags ?? this.tags,
    blacklistedTags: blacklistedTags ?? this.blacklistedTags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'notifications': notifications,
    'skipIfExists': skipIfExists,
    'quality': quality,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'perPage': perPage,
    'concurrency': concurrency,
    'tags': tags,
    'blacklistedTags': blacklistedTags,
  };

  @override
  List<Object?> get props => [
    id,
    path,
    notifications,
    skipIfExists,
    quality,
    createdAt,
    updatedAt,
    perPage,
    concurrency,
    tags,
    blacklistedTags,
  ];
}
