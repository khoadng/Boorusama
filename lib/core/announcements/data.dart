// Package imports:
import 'package:booru_clients/boorusama.dart';

// Project imports:
import '../../foundation/loggers.dart';
import 'filter.dart';
import 'types.dart';

const _kAnnouncementServiceName = 'Announcement';

class AnnouncementRepository {
  const AnnouncementRepository({
    required this.client,
    required this.matcher,
    required this.logger,
  });

  final BoorusamaClient client;
  final AnnouncementMatcher matcher;
  final Logger logger;

  Future<List<AppAnnouncement>> getAnnouncements({
    required String booruKey,
    required String host,
    required Future<Set<String>> dismissedIds,
  }) async {
    BoorusamaAnnouncementIndex index;
    try {
      index = await client.getAnnouncementIndex();
    } catch (e) {
      logger.warn(
        _kAnnouncementServiceName,
        'Failed to load structured announcement index, falling back to legacy: $e',
      );
      return _getLegacyAnnouncements();
    }

    if (!index.isSupported) {
      logger.warn(
        _kAnnouncementServiceName,
        'Unsupported announcement schema version ${index.schemaVersion}, falling back to legacy.',
      );
      return _getLegacyAnnouncements();
    }

    final paths = [
      index.files.global,
      index.files.boorus[booruKey],
      index.files.hosts[host],
    ].whereType<String>().toSet();

    final loadedFiles = await Future.wait(
      paths.map((path) async {
        try {
          return await client.getAnnouncementFile(path);
        } catch (e) {
          logger.warn(
            _kAnnouncementServiceName,
            'Failed to load announcement file "$path", skipping it: $e',
          );
          return const BoorusamaAnnouncementFile(announcements: []);
        }
      }),
    );

    final context = AnnouncementContext(
      now: DateTime.now().toUtc(),
      dismissedIds: await dismissedIds,
    );
    final filtered =
        loadedFiles
            .expand((file) => file.announcements)
            .where(
              (announcement) => matcher.matches(announcement, context),
            )
            .toList()
          ..sort(matcher.compare);

    return _deduplicateAnnouncements(
      filtered,
    ).take(3).map(AppAnnouncement.fromRemote).toList();
  }

  Future<List<AppAnnouncement>> _getLegacyAnnouncements() async {
    try {
      final html = await client.getLegacyAnnouncement();
      return html.trimRight().isNotEmpty
          ? [AppAnnouncement.legacy(contentHtml: html)]
          : const [];
    } catch (e) {
      logger.warn(
        _kAnnouncementServiceName,
        'Failed to load legacy announcement: $e',
      );
      return const [];
    }
  }
}

String normalizeAnnouncementHost(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';

  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z\d+\-.]*://').hasMatch(trimmed);
  final normalizedInput = hasScheme ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(normalizedInput);
  if (uri == null || uri.host.isEmpty) return '';

  final host = uri.host.toLowerCase();
  if (!uri.hasPort || uri.port == 80 || uri.port == 443) return host;

  return '$host:${uri.port}';
}

Iterable<BoorusamaAnnouncement> _deduplicateAnnouncements(
  List<BoorusamaAnnouncement> announcements,
) sync* {
  final seenIds = <String>{};
  for (final announcement in announcements) {
    if (seenIds.add(announcement.id)) {
      yield announcement;
    }
  }
}
