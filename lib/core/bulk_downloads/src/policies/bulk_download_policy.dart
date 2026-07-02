// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/booru/types.dart';
import '../../../configs/config/types.dart';
import '../types/download_record.dart';

final bulkDownloadPolicyProvider =
    Provider.family<BulkDownloadPolicy, BooruConfigAuth>((ref, config) {
      return switch (config.booruType) {
        BooruType.animePictures => const PoliteBulkDownloadPolicy(),
        _ => DefaultBulkDownloadPolicy(
          canCreateBulkTask: config.booruType.canDownloadMultipleFiles,
        ),
      };
    });

abstract interface class BulkDownloadPolicy {
  String get id;
  bool get canCreateBulkTask;
  bool get isPolite;
  int? get maxRecordsPerSession;
  int get maxConsecutiveMissingUrls;
  bool get waitForRecordCompletion;

  Duration delayBeforeResolvingUrl({
    required int page,
    required int pageIndex,
  });

  Duration delayBetweenPages({
    required int currentPage,
  });

  Duration delayBetweenDownloads({
    required DownloadRecord record,
    required int recordIndex,
  });

  bool shouldStopAfterTerminalFailure(Object error);
}

class DefaultBulkDownloadPolicy implements BulkDownloadPolicy {
  const DefaultBulkDownloadPolicy({
    required this.canCreateBulkTask,
  });

  @override
  final bool canCreateBulkTask;

  @override
  String get id => 'default';

  @override
  bool get isPolite => false;

  @override
  int? get maxRecordsPerSession => null;

  @override
  int get maxConsecutiveMissingUrls => 0;

  @override
  bool get waitForRecordCompletion => false;

  @override
  Duration delayBeforeResolvingUrl({
    required int page,
    required int pageIndex,
  }) => Duration.zero;

  @override
  Duration delayBetweenPages({
    required int currentPage,
  }) => const Duration(milliseconds: 200);

  @override
  Duration delayBetweenDownloads({
    required DownloadRecord record,
    required int recordIndex,
  }) => const Duration(milliseconds: 200);

  @override
  bool shouldStopAfterTerminalFailure(Object error) => false;
}

class PoliteBulkDownloadPolicy implements BulkDownloadPolicy {
  const PoliteBulkDownloadPolicy();

  @override
  String get id => 'polite';

  @override
  bool get canCreateBulkTask => true;

  @override
  bool get isPolite => true;

  @override
  int get maxRecordsPerSession => 50;

  @override
  int get maxConsecutiveMissingUrls => 3;

  @override
  bool get waitForRecordCompletion => true;

  @override
  Duration delayBeforeResolvingUrl({
    required int page,
    required int pageIndex,
  }) =>
      page == 1 && pageIndex == 0 ? Duration.zero : const Duration(seconds: 5);

  @override
  Duration delayBetweenPages({
    required int currentPage,
  }) => const Duration(seconds: 10);

  @override
  Duration delayBetweenDownloads({
    required DownloadRecord record,
    required int recordIndex,
  }) => const Duration(seconds: 5);

  @override
  bool shouldStopAfterTerminalFailure(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('403') ||
        message.contains('429') ||
        message.contains('access denied') ||
        message.contains('too many requests');
  }
}
