// Package imports:
import 'package:equatable/equatable.dart';

class DownloadTaskVersion extends Equatable {
  const DownloadTaskVersion({
    required this.id,
    required this.taskId,
    required this.version,
    required this.path,
    required this.notifications,
    required this.skipIfExists,
    required this.perPage,
    required this.concurrency,
    required this.createdAt,
    this.quality,
    this.tags,
  });

  final int id;
  final String taskId;
  final int version;
  final String path;
  final bool notifications;
  final bool skipIfExists;
  final String? quality;
  final int perPage;
  final int concurrency;
  final String? tags;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        taskId,
        version,
        path,
        notifications,
        skipIfExists,
        quality,
        perPage,
        concurrency,
        tags,
        createdAt,
      ];
}
