// Package imports:
import 'package:booru_clients/boorusama.dart';

// Project imports:
import '../environment/types.dart';
import '../../foundation/platform.dart';
import 'types.dart';

class AnnouncementMatcher {
  const AnnouncementMatcher({
    required this.environment,
  });

  final AppEnvironment environment;

  bool matches(
    BoorusamaAnnouncement announcement,
    AnnouncementContext context,
  ) {
    if (announcement.id.isEmpty) return false;
    if (announcement.contentHtml.trimRight().isEmpty) return false;
    if (context.dismissedIds.contains(announcement.id)) return false;

    final startsAt = announcement.startsAt;
    if (startsAt != null && context.now.isBefore(startsAt)) return false;

    final endsAt = announcement.endsAt;
    if (endsAt != null && !context.now.isBefore(endsAt)) return false;

    final appVersions = announcement.appVersions;
    if (appVersions != null) {
      final version = environment.appVersion;
      if (version == null) return false;
      if (!appVersions.contains(version)) return false;
    }

    final platforms = announcement.platforms;
    if (platforms != null && platforms.isNotEmpty) {
      final normalizedPlatforms = platforms.map((e) => e.toLowerCase()).toSet();
      if (!normalizedPlatforms.contains(environment.platform.wireName)) {
        return false;
      }
    }

    final builds = announcement.builds;
    if (builds != null && builds.isNotEmpty) {
      final normalizedBuilds = builds.map((e) => e.toLowerCase()).toSet();
      if (!normalizedBuilds.contains(environment.build.wireName)) {
        return false;
      }
    }

    final channels = announcement.channels;
    if (channels != null && channels.isNotEmpty) {
      final normalizedChannels = channels.map((e) => e.toLowerCase()).toSet();
      if (!normalizedChannels.contains(environment.channel.wireName)) {
        return false;
      }
    }

    final modes = announcement.modes;
    if (modes != null && modes.isNotEmpty) {
      final normalizedModes = modes.map((e) => e.toLowerCase()).toSet();
      if (!normalizedModes.contains(environment.mode.wireName)) {
        return false;
      }
    }

    final devices = announcement.devices;
    if (devices != null && devices.isNotEmpty) {
      final normalizedDevices = devices.map((e) => e.toLowerCase()).toSet();
      if (!normalizedDevices.contains(environment.device.wireName)) {
        return false;
      }
    }

    if (!_matchesLanguages(announcement.languages, environment.languages)) {
      return false;
    }

    if (!_matchesOs(
      announcement.os,
      platform: environment.platform.wireName,
      osInfo: environment.os,
    )) {
      return false;
    }

    return true;
  }

  int compare(
    BoorusamaAnnouncement a,
    BoorusamaAnnouncement b,
  ) {
    final priority = b.priority.compareTo(a.priority);
    if (priority != 0) return priority;

    final severity = _severityRank(
      b.severity,
    ).compareTo(_severityRank(a.severity));
    if (severity != 0) return severity;

    final startsAt = _compareNullableDateDesc(a.startsAt, b.startsAt);
    if (startsAt != 0) return startsAt;

    return a.id.compareTo(b.id);
  }

  bool _matchesOs(
    BoorusamaAnnouncementOsTargets? os, {
    required String platform,
    required AppOsInfo osInfo,
  }) {
    if (os == null) return true;

    final rule = os.rules[platform.toLowerCase()];
    if (rule == null) return false;

    return _matchesOsRule(rule, osInfo);
  }

  bool _matchesLanguages(
    Set<String>? announcementLanguages,
    List<String> userLanguages,
  ) {
    if (announcementLanguages == null || announcementLanguages.isEmpty) {
      return true;
    }

    final normalizedUserLanguages = userLanguages
        .map(_normalizeLanguageTag)
        .where((language) => language.isNotEmpty)
        .toList();
    if (normalizedUserLanguages.isEmpty) return false;

    for (final announcementLanguage in announcementLanguages) {
      final normalizedAnnouncementLanguage = _normalizeLanguageTag(
        announcementLanguage,
      );
      if (normalizedAnnouncementLanguage.isEmpty) continue;

      final exactMatch = normalizedAnnouncementLanguage.contains('-');

      for (final userLanguage in normalizedUserLanguages) {
        if (exactMatch) {
          if (userLanguage == normalizedAnnouncementLanguage) return true;
        } else if (_languageCode(userLanguage) ==
            normalizedAnnouncementLanguage) {
          return true;
        }
      }
    }

    return false;
  }

  bool _matchesOsRule(
    BoorusamaAnnouncementOsRule rule,
    AppOsInfo osInfo,
  ) {
    final sdk = rule.sdk;
    if (sdk != null) {
      final androidSdk = osInfo.androidSdk;
      if (androidSdk == null || !sdk.contains(androidSdk)) return false;
    }

    final version = rule.version;
    if (version != null) {
      final osVersion = osInfo.version;
      if (osVersion == null || !version.contains(osVersion)) return false;
    }

    final distros = rule.distros;
    if (distros != null && distros.isNotEmpty) {
      final normalizedDistros = distros.map((e) => e.toLowerCase()).toSet();
      if (osInfo.linuxDistros.intersection(normalizedDistros).isEmpty) {
        return false;
      }
    }

    final versionIds = rule.versionIds;
    if (versionIds != null && versionIds.isNotEmpty) {
      final linuxVersionId = osInfo.linuxVersionId;
      if (linuxVersionId == null) return false;

      final normalizedVersionIds = versionIds
          .map((e) => e.toLowerCase())
          .toSet();
      if (!normalizedVersionIds.contains(linuxVersionId)) return false;
    }

    final browsers = rule.browsers;
    if (browsers != null && browsers.isNotEmpty) {
      final browser = osInfo.browser;
      if (browser == null) return false;

      final normalizedBrowsers = browsers.map((e) => e.toLowerCase()).toSet();
      if (!normalizedBrowsers.contains(browser)) return false;
    }

    return true;
  }
}

String _normalizeLanguageTag(String language) {
  return language.trim().replaceAll('_', '-').toLowerCase();
}

String _languageCode(String language) {
  return language.split('-').first;
}

int _severityRank(BoorusamaAnnouncementSeverity severity) {
  return switch (severity) {
    BoorusamaAnnouncementSeverity.critical => 3,
    BoorusamaAnnouncementSeverity.warning => 2,
    BoorusamaAnnouncementSeverity.info => 1,
  };
}

int _compareNullableDateDesc(DateTime? a, DateTime? b) {
  return switch ((a, b)) {
    (null, null) => 0,
    (null, _) => 1,
    (_, null) => -1,
    (final a?, final b?) => b.compareTo(a),
  };
}
