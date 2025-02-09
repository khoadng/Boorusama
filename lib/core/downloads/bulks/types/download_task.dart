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
