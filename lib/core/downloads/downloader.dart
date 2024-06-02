// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'download_status.dart';
import 'types.dart';

abstract class Downloader {
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required DownloadFilenameBuilder fileNameBuilder,
  });

  Future<void> pause(String url);
  Future<void> resume(String url);

  Future<void> cancelAll();

  Stream<DownloadStatus> get stream;
}

class QueueData extends Equatable {
  const QueueData(this.itemId, this.size);

  final String itemId;
  final int size;

  @override
  bool? get stringify => false;

  @override
  String toString() => itemId;

  @override
  List<Object?> get props => [itemId];
}
