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
