// Package imports:
import 'package:booru_clients/boorusama.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../foundation/url_launcher.dart';
import '../widgets/dismissable_info_container.dart';
import '../widgets/persistent_dismissable_info_container.dart';
import 'providers.dart';

class SliverAppAnnouncementBanner extends StatelessWidget {
  const SliverAppAnnouncementBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: AppAnnouncementBanner(),
    );
  }
}

class AppAnnouncementBanner extends ConsumerStatefulWidget {
  const AppAnnouncementBanner({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnnouncementBannerState();
}

class _AnnouncementBannerState extends ConsumerState<AppAnnouncementBanner> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(appAnnouncementsProvider)
        .maybeWhen(
          data: (announcements) => announcements.isNotEmpty
              ? Column(
                  children: [
                    for (final announcement in announcements)
                      _AnnouncementContainer(announcement: announcement),
                  ],
                )
              : const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        );
  }
}

class _AnnouncementContainer extends ConsumerWidget {
  const _AnnouncementContainer({
    required this.announcement,
  });

  final AppAnnouncement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = ref.read(externalUrlLauncherProvider);

    if (announcement.isLegacy || !announcement.dismissible) {
      return DismissableInfoContainer(
        content: announcement.contentHtml,
        forceShow: true,
        mainColor: Colors.orange[600],
        actions: _buildActions(context, announcement, launcher),
        onLinkTap: (url, _, _) => _openAnnouncementUrl(url, launcher),
        buttonsPadding: EdgeInsets.zero,
      );
    }

    return PersistentDismissableInfoContainer(
      storageKey: announcement.dismissalKey,
      content: announcement.contentHtml,
      mainColor: _colorForSeverity(announcement.severity),
      actions: _buildActions(context, announcement, launcher),
      onLinkTap: (url, _, _) => _openAnnouncementUrl(url, launcher),
      buttonsPadding: EdgeInsets.zero,
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    AppAnnouncement announcement,
    ExternalUrlLauncher launcher,
  ) {
    return [
      for (final action in announcement.actions)
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Kurumi.themeOf(context).colorScheme.onSurface,
          ),
          onPressed: () => _openAnnouncementAction(action, launcher),
          child: Text(action.label),
        ),
    ];
  }
}

void _openAnnouncementAction(
  AppAnnouncementAction action,
  ExternalUrlLauncher launcher,
) {
  _openAnnouncementUrl(action.url, launcher);
}

void _openAnnouncementUrl(String? url, ExternalUrlLauncher launcher) {
  if (url == null) return;

  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (uri.scheme != 'http' && uri.scheme != 'https') return;

  launchExternalUrl(uri, launcher: launcher);
}

Color? _colorForSeverity(BoorusamaAnnouncementSeverity severity) {
  return switch (severity) {
    BoorusamaAnnouncementSeverity.info => null,
    BoorusamaAnnouncementSeverity.warning => Colors.orange[600],
    BoorusamaAnnouncementSeverity.critical => Colors.red[700],
  };
}
