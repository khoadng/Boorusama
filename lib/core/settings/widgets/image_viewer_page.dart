// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_header.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'widgets/settings_page_scaffold.dart';

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
    final config = ref.watchConfig;

    return SettingsPageScaffold(
      padding: EdgeInsets.zero,
      title: const Text('settings.image_viewer.image_viewer').tr(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(label: 'settings.general'.tr()),
              SettingsTile(
                title:
                    const Text('settings.image_details.ui_overlay.ui_overlay')
                        .tr(),
                selectedOption: settings.postDetailsOverlayInitialState,
                items: PostDetailsOverlayInitialState.values,
                onChanged: (value) => ref.updateSettings(
                    settings.copyWith(postDetailsOverlayInitialState: value)),
                optionBuilder: (value) => Text(value.localize().tr()),
              ),
              const Divider(thickness: 1),
              const SettingsHeader(label: 'Slideshow'),
              SettingsTile(
                title: const Text('Slideshow mode'),
                selectedOption: settings.slideshowDirection,
                items: SlideshowDirection.values,
                onChanged: (value) => ref.updateSettings(
                    settings.copyWith(slideshowDirection: value)),
                optionBuilder: (value) => Text(value.localize().tr()),
              ),
              SettingsTile(
                title: const Text('Slideshow interval'),
                subtitle: const Text(
                    'Value less than 1 second will automatically skip transition'),
                selectedOption: settings.slideshowInterval,
                items: getSlideShowIntervalPossibleValue(),
                onChanged: (newValue) {
                  ref.updateSettings(
                      settings.copyWith(slideshowInterval: newValue));
                },
                optionBuilder: (value) => Text(
                  '${value.toStringAsFixed(value < 1 ? 2 : 0)} sec',
                ),
              ),
              SwitchListTile(
                title: const Text('Skip slideshow transition'),
                value: settings.skipSlideshowTransition,
                onChanged: (value) => ref.updateSettings(
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
                onChanged: (value) => ref.updateSettings(
                  settings.copyWith(
                    videoAudioDefaultState: value
                        ? VideoAudioDefaultState.mute
                        : VideoAudioDefaultState.unmute,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need more?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                ),
                onPressed: () {
                  goToUpdateBooruConfigPage(
                    context,
                    config: config,
                    initialTab: 'viewer',
                  );
                },
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> openImageViewerSettingsPage(BuildContext context) {
  return Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const ImageViewerPage(),
    ),
  );
}
