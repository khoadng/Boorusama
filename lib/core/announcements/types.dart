// Package imports:
import 'package:booru_clients/boorusama.dart';

const kAnnouncementDismissedPrefix = 'announcement_dismissed:';

class AnnouncementContext {
  const AnnouncementContext({
    required this.now,
    required this.dismissedIds,
  });

  final DateTime now;
  final Set<String> dismissedIds;
}

class AppAnnouncement {
  const AppAnnouncement({
    required this.id,
    required this.contentHtml,
    required this.severity,
    required this.isLegacy,
    required this.actions,
    required this.dismissible,
  });

  factory AppAnnouncement.fromRemote(
    BoorusamaAnnouncement announcement,
  ) {
    return AppAnnouncement(
      id: announcement.id,
      contentHtml: announcement.contentHtml,
      severity: announcement.severity,
      isLegacy: false,
      dismissible: announcement.dismissible,
      actions: announcement.actions
          .map(
            (action) => AppAnnouncementAction(
              label: action.label,
              url: action.url,
            ),
          )
          .toList(),
    );
  }

  const AppAnnouncement.legacy({
    required this.contentHtml,
  }) : id = '',
       severity = BoorusamaAnnouncementSeverity.warning,
       isLegacy = true,
       dismissible = false,
       actions = const [];

  final String id;
  final String contentHtml;
  final BoorusamaAnnouncementSeverity severity;
  final bool isLegacy;
  final bool dismissible;
  final List<AppAnnouncementAction> actions;

  String get dismissalKey => '$kAnnouncementDismissedPrefix$id';
}

class AppAnnouncementAction {
  const AppAnnouncementAction({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;
}
