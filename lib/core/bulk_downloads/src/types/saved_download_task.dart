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
  });

  factory SavedDownloadTask.empty() {
    return SavedDownloadTask(
      id: -1,
      task: DownloadTask.empty(),
      createdAt: DateTime(1),
    );
  }

  SavedDownloadTask copyWith({
    int? id,
    DownloadTask? task,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedDownloadTask(
      id: id ?? this.id,
      task: task ?? this.task,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  final int id;
  final DownloadTask task;
  final String? name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    task,
    name,
    createdAt,
    updatedAt,
  ];
}
