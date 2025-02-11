// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'download_task.dart';

class SavedDownloadTask extends Equatable {
  const SavedDownloadTask({
    required this.id,
    required this.task,
    required this.createdAt,
    this.name,
    this.updatedAt,
    this.activeVersionId,
  });

  final int id;
  final DownloadTask task;
  final String? name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? activeVersionId;

  @override
  List<Object?> get props => [
        id,
        task,
        name,
        createdAt,
        updatedAt,
        activeVersionId,
      ];
}
