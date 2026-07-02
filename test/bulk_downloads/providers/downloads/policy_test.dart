// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/boorus/booru/types.dart';
import 'package:boorusama/core/bulk_downloads/src/policies/bulk_download_policy.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/runtime_status.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_record.dart';
import 'package:boorusama/core/configs/config/types.dart';
import '../../../riverpod_test_utils.dart';

void main() {
  group('BulkDownloadPolicy', () {
    test('uses default policy for normal boorus', () {
      final config = BooruConfigAuth.fromConfig(
        BooruConfig.defaultConfig(
          booruType: BooruType.danbooru,
          url: 'https://danbooru.donmai.us',
          customDownloadFileNameFormat: null,
        ),
      );
      final container = createContainer();

      final policy = container.read(bulkDownloadPolicyProvider(config));

      expect(policy, isA<DefaultBulkDownloadPolicy>());
      expect(policy.canCreateBulkTask, isTrue);
      expect(policy.isPolite, isFalse);
      expect(policy.waitForRecordCompletion, isFalse);
      expect(policy.maxRecordsPerSession, isNull);
    });

    test('uses polite policy for Anime Pictures', () {
      final config = BooruConfigAuth.fromConfig(
        BooruConfig.defaultConfig(
          booruType: BooruType.animePictures,
          url: 'https://anime-pictures.net',
          customDownloadFileNameFormat: null,
        ),
      );
      final container = createContainer();

      final policy = container.read(bulkDownloadPolicyProvider(config));

      expect(policy, isA<PoliteBulkDownloadPolicy>());
      expect(policy.canCreateBulkTask, isTrue);
      expect(policy.isPolite, isTrue);
      expect(policy.waitForRecordCompletion, isTrue);
      expect(policy.maxRecordsPerSession, 50);
      expect(
        policy.delayBetweenDownloads(
          record: DownloadRecord(
            url: 'url',
            sessionId: 'session',
            status: DownloadRecordStatus.pending,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime(1),
            fileName: 'file.jpg',
          ),
          recordIndex: 0,
        ),
        const Duration(seconds: 5),
      );
    });

    test('polite policy stops on protection-like errors', () {
      const policy = PoliteBulkDownloadPolicy();

      expect(
        policy.shouldStopAfterTerminalFailure(Exception('HTTP 429')),
        isTrue,
      );
      expect(
        policy.shouldStopAfterTerminalFailure(Exception('captcha')),
        isFalse,
      );
      expect(
        policy.shouldStopAfterTerminalFailure(
          Exception('cloudflare protection'),
        ),
        isFalse,
      );
      expect(
        policy.shouldStopAfterTerminalFailure(Exception('network')),
        isFalse,
      );
    });
  });

  group('BulkDownloadRuntimeStatusNotifier', () {
    test('sets and clears session status', () {
      final container = createContainer();
      final notifier = container.read(
        bulkDownloadRuntimeStatusProvider.notifier,
      );

      notifier.set(
        'session-1',
        const BulkDownloadRuntimeStatus(
          stage: BulkDownloadRuntimeStage.waitingBeforeRequest,
          remaining: Duration(seconds: 3),
        ),
      );

      expect(
        container.read(bulkDownloadRuntimeStatusProvider)['session-1']?.stage,
        BulkDownloadRuntimeStage.waitingBeforeRequest,
      );

      notifier.clear('session-1');

      expect(
        container
            .read(bulkDownloadRuntimeStatusProvider)
            .containsKey(
              'session-1',
            ),
        isFalse,
      );
    });
  });
}
