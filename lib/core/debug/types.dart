// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../foundation/loggers.dart';

sealed class WriteLogStatus {
  const WriteLogStatus();
}

final class WriteLogSuccess extends WriteLogStatus {
  const WriteLogSuccess(this.filePath);

  final String filePath;
}

final class WriteLogFailure extends WriteLogStatus {
  const WriteLogFailure(this.message);

  final String message;
}

extension FormatX on LogData {
  String format() {
    final msg = tryDecodeFullUri(message).getOrElse(() => message);

    return msg;
  }
}
