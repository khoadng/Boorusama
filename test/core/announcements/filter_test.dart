// Package imports:
import 'package:booru_clients/boorusama.dart';
import 'package:boorusama/core/announcements/filter.dart';
import 'package:boorusama/core/announcements/types.dart';
import 'package:boorusama/core/environment/data.dart';
import 'package:boorusama/core/environment/types.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:coreutils/coreutils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 5, 5, 12);

  AnnouncementContext context({
    DateTime? nowOverride,
    Set<String> dismissedIds = const {},
  }) {
    return AnnouncementContext(
      now: nowOverride ?? now,
      dismissedIds: dismissedIds,
    );
  }

  AnnouncementMatcher matcher({
    Version? appVersion,
    bool hasAppVersion = true,
    AppPlatform platform = AppPlatform.android,
    AppBuild build = AppBuild.standard,
    ReleaseChannel channel = ReleaseChannel.play,
    FlutterMode mode = FlutterMode.release,
    DeviceKind device = DeviceKind.physical,
    List<String> languages = const ['en-US'],
    AppOsInfo? osInfo,
  }) {
    return AnnouncementMatcher(
      environment: AppEnvironment(
        appVersion: hasAppVersion ? appVersion ?? Version(4, 4, 0) : null,
        platform: platform,
        build: build,
        channel: channel,
        mode: mode,
        device: device,
        languages: languages,
        os:
            osInfo ??
            AppOsInfo(
              androidSdk: 29,
              version: Version(10, 0, 0),
            ),
      ),
    );
  }

  group('AnnouncementMatcher.matches', () {
    test('accepts a minimal valid announcement', () {
      expect(
        matcher().matches(announcement(), context()),
        true,
      );
    });

    test('rejects invalid or dismissed announcements', () {
      final appMatcher = matcher();

      expect(
        appMatcher.matches(announcement(id: ''), context()),
        false,
      );
      expect(
        appMatcher.matches(announcement(contentHtml: '   '), context()),
        false,
      );
      expect(
        appMatcher.matches(
          announcement(id: 'dismissed'),
          context(dismissedIds: {'dismissed'}),
        ),
        false,
      );
    });

    test('applies start and end windows', () {
      final appMatcher = matcher();

      expect(
        appMatcher.matches(
          announcement(startsAt: now.add(const Duration(minutes: 1))),
          context(),
        ),
        false,
      );
      expect(
        appMatcher.matches(
          announcement(startsAt: now, endsAt: now.add(const Duration(days: 1))),
          context(),
        ),
        true,
      );
      expect(
        appMatcher.matches(
          announcement(endsAt: now),
          context(),
        ),
        false,
      );
    });

    test('applies app version ranges', () {
      expect(
        matcher(appVersion: Version(4, 4, 0)).matches(
          announcement(
            appVersions: versionRange(
              min: Version(4, 0, 0),
              max: Version(4, 4, 0),
            ),
          ),
          context(),
        ),
        true,
      );
      expect(
        matcher(appVersion: Version(4, 4, 0)).matches(
          announcement(appVersions: versionRange(min: Version(4, 5, 0))),
          context(),
        ),
        false,
      );
      expect(
        matcher(hasAppVersion: false).matches(
          announcement(appVersions: versionRange(max: Version(4, 4, 0))),
          context(),
        ),
        false,
      );
    });

    test(
      'applies platform, build, channel, mode, and device filters case-insensitively',
      () {
        expect(
          matcher().matches(
            announcement(platforms: {'ANDROID'}),
            context(),
          ),
          true,
        );
        expect(
          matcher(platform: AppPlatform.ios).matches(
            announcement(platforms: {'android'}),
            context(),
          ),
          false,
        );
        expect(
          matcher(build: AppBuild.foss).matches(
            announcement(builds: {'FOSS'}),
            context(),
          ),
          true,
        );
        expect(
          matcher().matches(
            announcement(builds: {'foss'}),
            context(),
          ),
          false,
        );
        expect(
          matcher(channel: ReleaseChannel.github).matches(
            announcement(channels: {'GITHUB'}),
            context(),
          ),
          true,
        );
        expect(
          matcher().matches(
            announcement(channels: {'github'}),
            context(),
          ),
          false,
        );
        expect(
          matcher(mode: FlutterMode.debug).matches(
            announcement(modes: {'DEBUG'}),
            context(),
          ),
          true,
        );
        expect(
          matcher().matches(
            announcement(modes: {'debug'}),
            context(),
          ),
          false,
        );
        expect(
          matcher(device: DeviceKind.virtual).matches(
            announcement(devices: {'VIRTUAL'}),
            context(),
          ),
          true,
        );
        expect(
          matcher().matches(
            announcement(devices: {'virtual'}),
            context(),
          ),
          false,
        );
      },
    );

    test('applies language filters', () {
      expect(
        matcher(languages: ['ja-JP']).matches(
          announcement(languages: {'ja'}),
          context(),
        ),
        true,
      );
      expect(
        matcher(languages: ['ja']).matches(
          announcement(languages: {'ja-JP'}),
          context(),
        ),
        false,
      );
      expect(
        matcher(languages: ['JA-jp']).matches(
          announcement(languages: {'ja_JP'}),
          context(),
        ),
        true,
      );
      expect(
        matcher(languages: const []).matches(
          announcement(languages: {'ja'}),
          context(),
        ),
        false,
      );
    });

    test('allows all OSes when os filter is omitted', () {
      expect(
        matcher(platform: AppPlatform.ios).matches(announcement(), context()),
        true,
      );
    });

    test('requires current platform when os filter is present', () {
      expect(
        matcher().matches(
          announcement(os: osTargets('ios')),
          context(),
        ),
        false,
      );
      expect(
        matcher().matches(
          announcement(os: osTargets('android')),
          context(),
        ),
        true,
      );
    });

    test('applies Android SDK filters', () {
      expect(
        matcher(osInfo: const AppOsInfo(androidSdk: 29)).matches(
          announcement(
            os: osTargets(
              'android',
              osRule(sdk: intRange(max: 29)),
            ),
          ),
          context(),
        ),
        true,
      );
      expect(
        matcher(osInfo: const AppOsInfo(androidSdk: 29)).matches(
          announcement(
            os: osTargets(
              'android',
              osRule(sdk: intRange(min: 30)),
            ),
          ),
          context(),
        ),
        false,
      );
    });

    test('applies OS version filters', () {
      expect(
        matcher(
          platform: AppPlatform.ios,
          osInfo: AppOsInfo(version: Version(17, 1, 0)),
        ).matches(
          announcement(
            os: osTargets(
              'ios',
              osRule(
                version: versionRange(
                  min: Version(16, 0, 0),
                  max: Version(17, 5, 0),
                ),
              ),
            ),
          ),
          context(),
        ),
        true,
      );
      expect(
        matcher(
          platform: AppPlatform.ios,
          osInfo: AppOsInfo(version: Version(17, 1, 0)),
        ).matches(
          announcement(
            os: osTargets(
              'ios',
              osRule(version: versionRange(min: Version(18, 0, 0))),
            ),
          ),
          context(),
        ),
        false,
      );
    });

    test('applies Linux distro and version id filters', () {
      final linuxMatcher = matcher(
        platform: AppPlatform.linux,
        osInfo: const AppOsInfo(
          linuxDistros: {'ubuntu', 'debian'},
          linuxVersionId: '22.04',
        ),
      );

      expect(
        linuxMatcher.matches(
          announcement(
            os: osTargets(
              'linux',
              osRule(distros: {'debian'}, versionIds: {'22.04'}),
            ),
          ),
          context(),
        ),
        true,
      );
      expect(
        linuxMatcher.matches(
          announcement(
            os: osTargets(
              'linux',
              osRule(distros: {'fedora'}),
            ),
          ),
          context(),
        ),
        false,
      );
      expect(
        linuxMatcher.matches(
          announcement(
            os: osTargets(
              'linux',
              osRule(versionIds: {'24.04'}),
            ),
          ),
          context(),
        ),
        false,
      );
    });

    test('applies web browser filters', () {
      expect(
        matcher(
          platform: AppPlatform.web,
          osInfo: const AppOsInfo(browser: 'chrome'),
        ).matches(
          announcement(
            os: osTargets(
              'web',
              osRule(browsers: {'chrome'}),
            ),
          ),
          context(),
        ),
        true,
      );
      expect(
        matcher(
          platform: AppPlatform.web,
          osInfo: const AppOsInfo(browser: 'chrome'),
        ).matches(
          announcement(
            os: osTargets(
              'web',
              osRule(browsers: {'firefox'}),
            ),
          ),
          context(),
        ),
        false,
      );
    });
  });

  group('AnnouncementMatcher.compare', () {
    test('sorts by priority, severity, start time, then id', () {
      final appMatcher = matcher();
      final announcements = [
        announcement(
          id: 'b',
          priority: 10,
          startsAt: DateTime.utc(2026, 5, 4),
        ),
        announcement(
          id: 'a',
          priority: 10,
          startsAt: DateTime.utc(2026, 5, 4),
        ),
        announcement(
          id: 'newer',
          priority: 10,
          startsAt: DateTime.utc(2026, 5, 5),
        ),
        announcement(
          id: 'critical',
          priority: 10,
          severity: BoorusamaAnnouncementSeverity.critical,
        ),
        announcement(
          id: 'highest-priority',
          priority: 20,
        ),
      ]..sort(appMatcher.compare);

      expect(
        announcements.map((announcement) => announcement.id),
        [
          'highest-priority',
          'critical',
          'newer',
          'a',
          'b',
        ],
      );
    });
  });

  group('currentReleaseChannel', () {
    test('uses explicit release channel when provided', () {
      expect(
        currentReleaseChannel(
          releaseChannel: 'github',
        ),
        ReleaseChannel.github,
      );
    });

    test('defaults to unknown without an explicit release channel', () {
      expect(
        currentReleaseChannel(
          releaseChannel: '',
        ),
        ReleaseChannel.unknown,
      );
    });

    test('maps unknown release channels to unknown', () {
      expect(
        currentReleaseChannel(
          releaseChannel: 'future-store',
        ),
        ReleaseChannel.unknown,
      );
    });
  });
}

BoorusamaAnnouncement announcement({
  String id = 'announcement',
  int priority = 0,
  BoorusamaAnnouncementSeverity severity = BoorusamaAnnouncementSeverity.info,
  DateTime? startsAt,
  DateTime? endsAt,
  BoorusamaAnnouncementVersionRange? appVersions,
  Set<String>? platforms,
  Set<String>? builds,
  Set<String>? channels,
  Set<String>? modes,
  Set<String>? devices,
  Set<String>? languages,
  BoorusamaAnnouncementOsTargets? os,
  String contentHtml = 'Announcement body',
}) {
  return BoorusamaAnnouncement(
    id: id,
    priority: priority,
    severity: severity,
    startsAt: startsAt,
    endsAt: endsAt,
    appVersions: appVersions,
    platforms: platforms,
    builds: builds,
    channels: channels,
    modes: modes,
    devices: devices,
    languages: languages,
    os: os,
    contentHtml: contentHtml,
    actions: const [],
    dismissible: true,
  );
}

BoorusamaAnnouncementVersionRange versionRange({
  Version? min,
  Version? max,
}) {
  return BoorusamaAnnouncementVersionRange(min: min, max: max);
}

BoorusamaAnnouncementIntRange intRange({
  int? min,
  int? max,
}) {
  return BoorusamaAnnouncementIntRange(min: min, max: max);
}

BoorusamaAnnouncementOsTargets osTargets(
  String platform, [
  BoorusamaAnnouncementOsRule? rule,
]) {
  return BoorusamaAnnouncementOsTargets(
    rules: {
      platform: rule ?? osRule(),
    },
  );
}

BoorusamaAnnouncementOsRule osRule({
  BoorusamaAnnouncementIntRange? sdk,
  BoorusamaAnnouncementVersionRange? version,
  Set<String>? distros,
  Set<String>? versionIds,
  Set<String>? browsers,
}) {
  return BoorusamaAnnouncementOsRule(
    sdk: sdk,
    version: version,
    distros: distros,
    versionIds: versionIds,
    browsers: browsers,
  );
}
