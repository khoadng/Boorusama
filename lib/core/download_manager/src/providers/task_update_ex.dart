// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../downloads/background/types.dart';
import '../../../downloads/downloader/types.dart';
import '../../../http/client/types.dart';

extension TaskUpdateX on TaskUpdate {
  int? get fileSize => switch (this) {
    final TaskStatusUpdate s => () {
      final defaultSize = DownloaderMetadata.fromJsonString(
        task.metaData,
      ).fileSize;
      final fileSizeString = s.responseHeaders.toOption().fold(
        () => '',
        (headers) => headers[AppHttpHeaders.contentLengthHeader],
      );
      final fileSize = fileSizeString != null
          ? int.tryParse(fileSizeString)
          : null;

      return fileSize ?? defaultSize;
    }(),
    final TaskProgressUpdate p => p.expectedFileSize,
  };
}
