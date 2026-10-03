// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../widgets/more_settings_redirect_card.dart';
import '../widgets/settings_interaction_blocker.dart';
import '../widgets/settings_page_scaffold.dart';
import 'appearance/image_viewer_settings_section.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  const ImageViewerPage({
    super.key,
  });
  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);
    return SettingsPageScaffold(
      title: Text(context.t.settings.image_viewer.image_viewer),
      children: [
        ViewerSettingsInteractionBlocker(
          child: ImageViewerSettingsSection(
            viewer: settings.viewer,
            onUpdate: (viewerSettings) => notifer.updateSettings(
              settings.copyWith(viewer: viewerSettings),
            ),
          ),
        ),

        BooruConfigMoreSettingsRedirectCard.imageViewer(
          extraActions: [
            RedirectAction(
              label: context.t.settings.accessibility.accessibility,
              onPressed: () => SettingsPageNavigationScope.of(
                context,
              ).openDestination('accessibility'),
            ),
          ],
        ),
      ],
    );
  }
}
