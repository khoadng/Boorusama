// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../search/selected_tags/types.dart';
import '../../../downloads/sidecar/types.dart';

class DownloadTask extends Equatable {
  const DownloadTask({
    required this.id,
    required this.path,
    required this.skipIfExists,
    required this.createdAt,
    required this.updatedAt,
    required this.perPage,
    required this.concurrency,
    this.quality,
    this.tags,
    this.blacklistedTags,
    this.sidecarFormat,
  });

  factory DownloadTask.empty() {
    return DownloadTask(
      id: '',
      path: '',
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
    sidecarFormat: json['sidecarFormat'] == null
        ? null
        : SidecarFormat.parse(json['sidecarFormat']),
  );

  final String id;
  final String path;
  final bool skipIfExists;
  final String? quality;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int perPage;
  final int concurrency;
  final String? tags;
  final String? blacklistedTags;
  final SidecarFormat? sidecarFormat;

  String? get prettyTags => tags == null
      ? null
      : SearchTagSet.fromString(tags).spaceDelimitedOriginalTags;

  DownloadTask copyWith({
    String? path,
    bool? skipIfExists,
    String? quality,
    int? perPage,
    int? concurrency,
    String? tags,
    String? blacklistedTags,
    SidecarFormat? Function()? sidecarFormat,
  }) => DownloadTask(
    id: id,
    path: path ?? this.path,
    skipIfExists: skipIfExists ?? this.skipIfExists,
    quality: quality ?? this.quality,
    createdAt: createdAt,
    updatedAt: updatedAt,
    perPage: perPage ?? this.perPage,
    concurrency: concurrency ?? this.concurrency,
    tags: tags ?? this.tags,
    blacklistedTags: blacklistedTags ?? this.blacklistedTags,
    sidecarFormat: sidecarFormat != null ? sidecarFormat() : this.sidecarFormat,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'skipIfExists': skipIfExists,
    'quality': quality,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'perPage': perPage,
    'concurrency': concurrency,
    'tags': tags,
    'blacklistedTags': blacklistedTags,
    'sidecarFormat': sidecarFormat?.name,
  };

  @override
  List<Object?> get props => [
    id,
    path,
    skipIfExists,
    quality,
    createdAt,
    updatedAt,
    perPage,
    concurrency,
    tags,
    blacklistedTags,
    sidecarFormat,
  ];
}
