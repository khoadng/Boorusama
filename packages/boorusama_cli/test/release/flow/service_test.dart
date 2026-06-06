import 'dart:io';

import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/flow/options.dart';
import 'package:boorusama_cli/src/release/flow/plan.dart';
import 'package:boorusama_cli/src/release/flow/retry.dart';
import 'package:test/test.dart';

import '../test_support/flow_fakes.dart';
import '../test_support/prepare_plan.dart';

void main() {
  group('planning and validation', () {
    test('plans shared phases and registered destinations', () async {
      final service = releaseFlowService();

      final plan = await service.plan(_options());

      expect(plan.preparePhase.status, ReleaseFlowStepStatus.pending);
      expect(plan.tagPhase?.status, ReleaseFlowStepStatus.pending);
      expect(plan.destinationPlans.map((destination) => destination.id), [
        'play',
        'github',
      ]);
      expect(
        plan.destinationPlans.map((destination) => destination.status),
        [
          ReleaseFlowStepStatus.pending,
          ReleaseFlowStepStatus.pending,
        ],
      );
    });

    test('validates the planned release flow', () async {
      final prepare = FakePrepareStep();
      final service = releaseFlowService(prepare: prepare);
      final plan = await service.plan(_options());

      service.validate(plan);

      expect(prepare.validated, isTrue);
    });

    test('rejects invalid release version during validation', () async {
      final service = releaseFlowService(
        prepare: FakePrepareStep(
          useRealValidation: true,
          plan: preparePlan(
            versionName: '1.2',
            nextFullVersion: '1.2+11',
            branch: '1.2',
            tag: 'v1.2',
          ),
        ),
      );
      final plan = await service.plan(_options());

      expect(() => service.validate(plan), throwsA(isA<ProcessFailure>()));
    });

    test('validation rejects blocked phase status', () async {
      final service = releaseFlowService(
        prepare: FakePrepareStep(done: true),
        tag: FakeTagStep(failsStatusCheck: true),
      );
      final plan = await service.plan(_options());

      expect(plan.tagPhase?.status, ReleaseFlowStepStatus.blocked);
      expect(() => service.validate(plan), throwsA(isA<ProcessFailure>()));
    });

    test(
      'plans complete when Play production and GitHub are published',
      () async {
        final prepare = FakePrepareStep(
          useRealValidation: true,
          plan: preparePlan(
            googlePlay: googlePlayPreparePlan(productionVersionName: '1.2.3'),
          ),
        );
        final service = releaseFlowService(
          prepare: prepare,
          tag: FakeTagStep(failsStatusCheck: true),
          destinations: [
            FakeDestination(
              id: 'play',
              label: 'Google Play',
              stepStatus: ReleaseFlowStepStatus.complete,
              planEarly: true,
            ),
            FakeDestination(
              id: 'github',
              label: 'GitHub',
              stepStatus: ReleaseFlowStepStatus.complete,
              planEarly: true,
              requiresTag: true,
            ),
          ],
        );

        final plan = await service.plan(_options());

        expect(plan.status, ReleaseFlowStatus.complete);
        expect(plan.preparePhase.status, ReleaseFlowStepStatus.complete);
        expect(plan.tagPhase?.status, ReleaseFlowStepStatus.complete);
        expect(
          plan.destinationPlans.map((destination) => destination.status),
          [
            ReleaseFlowStepStatus.complete,
            ReleaseFlowStepStatus.complete,
          ],
        );
        service.validate(plan);
        expect(prepare.validated, isFalse);
      },
    );

    test(
      'plans waiting when Play production is live but GitHub is draft',
      () async {
        final service = releaseFlowService(
          tag: FakeTagStep(done: true),
          prepare: FakePrepareStep(
            plan: preparePlan(
              googlePlay: googlePlayPreparePlan(productionVersionName: '1.2.3'),
            ),
          ),
          destinations: [
            FakeDestination(
              id: 'play',
              label: 'Google Play',
              stepStatus: ReleaseFlowStepStatus.complete,
              planEarly: true,
            ),
            FakeDestination(
              id: 'github',
              label: 'GitHub',
              stepStatus: ReleaseFlowStepStatus.waitingManualPublish,
              planEarly: true,
              requiresTag: true,
            ),
          ],
        );

        final plan = await service.plan(_options());

        expect(plan.status, ReleaseFlowStatus.waitingManualPublish);
        expect(plan.preparePhase.status, ReleaseFlowStepStatus.complete);
        expect(plan.tagPhase?.status, ReleaseFlowStepStatus.done);
        expect(
          plan.destinationPlans.map((destination) => destination.status),
          [
            ReleaseFlowStepStatus.complete,
            ReleaseFlowStepStatus.waitingManualPublish,
          ],
        );
      },
    );

    test('still blocks versions lower than Play production', () async {
      final service = releaseFlowService(
        prepare: FakePrepareStep(
          useRealValidation: true,
          plan: preparePlan(
            googlePlay: googlePlayPreparePlan(productionVersionName: '1.2.4'),
          ),
        ),
      );
      final plan = await service.plan(_options());

      expect(plan.status, ReleaseFlowStatus.pending);
      expect(() => service.validate(plan), throwsA(isA<ProcessFailure>()));
    });
  });

  group('apply and resume', () {
    test('applies release phases and destinations in order', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        tag: FakeTagStep(log: log),
        destinations: [
          FakeDestination(id: 'play', label: 'Google Play', log: log),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      await service.apply(plan);

      expect(log, ['prepare', 'play', 'tag', 'github']);
    });

    test('skips phases and destinations that are already done', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log, done: true),
        tag: FakeTagStep(log: log, done: true),
        destinations: [
          FakeDestination(id: 'play', label: 'Google Play', log: log),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      await service.apply(plan);

      expect(log, ['play', 'github']);
      expect(plan.preparePhase.status, ReleaseFlowStepStatus.done);
      expect(plan.tagPhase?.status, ReleaseFlowStepStatus.done);
      expect(
        plan.destinationPlans.map((destination) => destination.status),
        [
          ReleaseFlowStepStatus.pending,
          ReleaseFlowStepStatus.pending,
        ],
      );
    });

    test('skips waiting manual publish destinations during apply', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log, done: true),
        tag: FakeTagStep(log: log, done: true),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            stepStatus: ReleaseFlowStepStatus.waitingManualPublish,
          ),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            stepStatus: ReleaseFlowStepStatus.waitingManualPublish,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      expect(plan.status, ReleaseFlowStatus.waitingManualPublish);
      await service.apply(plan);

      expect(log, isEmpty);
    });

    test('omits tag phase when no active destination requires a tag', () async {
      final service = releaseFlowService(
        destinations: [FakeDestination(id: 'play', label: 'Google Play')],
      );

      final plan = await service.plan(_options());

      expect(plan.tagPhase, isNull);
      expect(plan.destinationPlans.map((destination) => destination.id), [
        'play',
      ]);
    });

    test('orchestrates extra destination without service changes', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        tag: FakeTagStep(log: log),
        destinations: [
          FakeDestination(id: 'play', label: 'Google Play', log: log),
          FakeDestination(id: 'appStore', label: 'App Store', log: log),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            requiresTag: true,
          ),
        ],
      );

      final plan = await service.plan(_options());

      expect(plan.destinationPlans.map((destination) => destination.id), [
        'play',
        'appStore',
        'github',
      ]);

      await service.apply(plan);

      expect(log, ['prepare', 'play', 'appStore', 'tag', 'github']);
    });

    test('logs significant apply progress', () async {
      final progress = <String>[];
      final service = releaseFlowService(
        destinations: [FakeDestination(id: 'play', label: 'Google Play')],
        onProgress: progress.add,
      );
      final plan = await service.plan(_options());

      await service.apply(plan);

      expect(progress, [
        'Starting release flow apply.',
        'Checking Prepare release branch.',
        'Running Prepare release branch.',
        'Completed Prepare release branch.',
        'Checking Google Play.',
        'Running Google Play.',
        'Completed Google Play.',
        'Release flow apply completed.',
      ]);
    });
  });

  group('retry', () {
    test('retries transient destination failures and continues', () async {
      final log = <String>[];
      final progress = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        tag: FakeTagStep(log: log),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            failuresBeforeSuccess: 1,
            failure: const SocketException('connection reset'),
          ),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            requiresTag: true,
          ),
        ],
        retryPolicy: const ReleaseFlowRetryPolicy(baseDelay: Duration.zero),
        onProgress: progress.add,
      );
      final plan = await service.plan(_options());

      await service.apply(plan);

      expect(log, ['prepare', 'play', 'play', 'tag', 'github']);
      expect(
        progress,
        contains(
          startsWith(
            'Retrying Google Play after transient failure '
            '(attempt 2/3): ',
          ),
        ),
      );
    });

    test(
      'rechecks done state before retrying a half-successful destination',
      () async {
        final log = <String>[];
        final service = releaseFlowService(
          prepare: FakePrepareStep(done: true),
          destinations: [
            FakeDestination(
              id: 'play',
              label: 'Google Play',
              log: log,
              failuresBeforeSuccess: 1,
              doneAfterFailure: true,
              failure: const SocketException('connection reset'),
            ),
          ],
          retryPolicy: const ReleaseFlowRetryPolicy(baseDelay: Duration.zero),
        );
        final plan = await service.plan(_options());

        await service.apply(plan);

        expect(log, ['play']);
      },
    );

    test('retries transient destination status check failures', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(done: true),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            statusFailuresBeforeSuccess: 1,
            statusFailuresAfterChecks: 1,
            statusFailure: const ProcessFailure(
              'Google Play API returned HTTP 503.',
            ),
          ),
        ],
        retryPolicy: const ReleaseFlowRetryPolicy(baseDelay: Duration.zero),
      );
      final plan = await service.plan(_options());

      await service.apply(plan);

      expect(log, ['play']);
    });

    test('does not retry non-transient business failures', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            fails: true,
            failure: const ProcessFailure('Current versionCode is not newer.'),
          ),
        ],
        retryPolicy: const ReleaseFlowRetryPolicy(baseDelay: Duration.zero),
      );
      final plan = await service.plan(_options());

      await expectLater(service.apply(plan), throwsA(isA<ProcessFailure>()));

      expect(log, ['prepare', 'play', 'rollbackPrepare']);
    });

    test('rolls back after retry attempts are exhausted', () async {
      final log = <String>[];
      final progress = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            failuresBeforeSuccess: 3,
            failure: const SocketException('connection reset'),
          ),
        ],
        retryPolicy: const ReleaseFlowRetryPolicy(
          maxAttempts: 2,
          baseDelay: Duration.zero,
        ),
        onProgress: progress.add,
      );
      final plan = await service.plan(_options());

      await expectLater(service.apply(plan), throwsA(isA<SocketException>()));

      expect(log, ['prepare', 'play', 'play', 'rollbackPrepare']);
      expect(progress, contains('Rolling back Prepare release branch.'));
    });
  });

  group('rollback', () {
    test('does not trigger later destinations after a failure', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        tag: FakeTagStep(log: log),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            fails: true,
          ),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      await expectLater(service.apply(plan), throwsA(isA<ProcessFailure>()));
      expect(log, [
        'prepare',
        'play',
        'rollbackPrepare',
      ]);
    });

    test('rolls back completed items in reverse order', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log),
        tag: FakeTagStep(log: log),
        destinations: [
          FakeDestination(id: 'play', label: 'Google Play', log: log),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            fails: true,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      await expectLater(service.apply(plan), throwsA(isA<ProcessFailure>()));

      expect(log, [
        'prepare',
        'play',
        'tag',
        'github',
        'rollbackTag',
        'rollbackplay',
        'rollbackPrepare',
      ]);
    });

    test('does not rollback skipped done items', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log, done: true),
        tag: FakeTagStep(log: log, done: true),
        destinations: [
          FakeDestination(id: 'play', label: 'Google Play', log: log),
          FakeDestination(
            id: 'github',
            label: 'GitHub',
            log: log,
            fails: true,
            requiresTag: true,
          ),
        ],
      );
      final plan = await service.plan(_options());

      await expectLater(service.apply(plan), throwsA(isA<ProcessFailure>()));

      expect(log, ['play', 'github', 'rollbackplay']);
    });

    test('keeps original failure when rollback fails', () async {
      final log = <String>[];
      final service = releaseFlowService(
        prepare: FakePrepareStep(log: log, rollbackFails: true),
        destinations: [
          FakeDestination(
            id: 'play',
            label: 'Google Play',
            log: log,
            fails: true,
            failure: const ProcessFailure('Play draft failed.'),
          ),
        ],
      );
      final plan = await service.plan(_options());

      await expectLater(
        service.apply(plan),
        throwsA(
          isA<ProcessFailure>().having(
            (error) => error.message,
            'message',
            'Play draft failed.',
          ),
        ),
      );
      expect(log, ['prepare', 'play', 'rollbackPrepare']);
    });
  });
}

ReleaseFlowOptions _options() {
  return ReleaseFlowOptions(
    versionName: '1.2.3',
    githubRepo: 'owner/repo',
    githubWorkflow: 'github-release.yml',
    playDraftTrack: 'internal',
    outputDir: Directory.systemTemp,
    releaseNotesLanguage: 'en-US',
  );
}
