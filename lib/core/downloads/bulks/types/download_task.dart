// Package imports:
import 'package:equatable/equatable.dart';

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
  });

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

  DownloadTask copyWith({
    String? path,
    bool? notifications,
    bool? skipIfExists,
    String? quality,
    int? perPage,
    int? concurrency,
    String? tags,
  }) =>
      DownloadTask(
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
      );

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
      ];
}
