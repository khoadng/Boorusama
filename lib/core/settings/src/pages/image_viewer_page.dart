// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../configs/redirect.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/types.dart';
import '../types/types_l10n.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_page_scaffold.dart';
import '../widgets/settings_tile.dart';

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
      title: const Text('settings.image_viewer.image_viewer').tr(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsHeader(label: 'settings.general'.tr()),
            SettingsTile(
              title: const Text('settings.image_details.ui_overlay.ui_overlay')
                  .tr(),
              selectedOption: settings.postDetailsOverlayInitialState,
              items: PostDetailsOverlayInitialState.values,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(postDetailsOverlayInitialState: value),
              ),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            const Divider(thickness: 1),
            const SettingsHeader(label: 'Slideshow'),
            SettingsTile(
              title: const Text('Slideshow mode'),
              selectedOption: settings.slideshowDirection,
              items: SlideshowDirection.values,
              onChanged: (value) => notifer
                  .updateSettings(settings.copyWith(slideshowDirection: value)),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            SettingsTile(
              title: const Text('Slideshow interval'),
              subtitle: const Text(
                'Value less than 1 second will automatically skip transition',
              ),
              selectedOption: settings.slideshowInterval,
              items: getSlideShowIntervalPossibleValue(),
              onChanged: (newValue) {
                notifer.updateSettings(
                  settings.copyWith(slideshowInterval: newValue),
                );
              },
              optionBuilder: (value) => Text(
                '${value.toStringAsFixed(value < 1 ? 2 : 0)} sec',
              ),
            ),
            SwitchListTile(
              title: const Text('Skip slideshow transition'),
              value: settings.skipSlideshowTransition,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  slideshowTransitionType: value
                      ? SlideshowTransitionType.none
                      : SlideshowTransitionType.natural,
                ),
              ),
            ),
            const Divider(thickness: 1),
            const SettingsHeader(label: 'Video'),
            SwitchListTile(
              title: const Text('Mute video by default'),
              value: settings.muteAudioByDefault,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  videoAudioDefaultState: value
                      ? VideoAudioDefaultState.mute
                      : VideoAudioDefaultState.unmute,
                ),
              ),
            ),
          ],
        ),
        const BooruConfigMoreSettingsRedirectCard.imageViewer(),
      ],
    );
  }
}

List<double> getSlideShowIntervalPossibleValue() => [
      0.1,
      0.25,
      0.5,
      ...[for (var i = 1; i <= 30; i += 1) i.toDouble()],
    ];