enum BulkDownloadErrorCode {
  taskNotFound('BD0001'),
  storagePermissionDenied('BD0002'),
  storagePermanentlyDenied('BD0003'),
  noRunningSession('BD0004'),
  noPostsFound('BD0005'),
  sessionNotFound('BD0006'),
  emptyTags('BD0007'),
  taskHasActiveSessions('BD0008'),
  downloadRecordNotFound('BD0009'),
  incompleteDownloads('BD0010'),
  sessionNotRunning('BD0011'),
  databaseOperation('BD0012'),
  nonPremiumResume('BD0013'),
  invalidSessionStatusForResume('BD0014'),
  unknown('BD9999');

  const BulkDownloadErrorCode(this.code);
  final String code;

  @override
  String toString() => code;
}
