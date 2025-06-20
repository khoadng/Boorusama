// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../configs/config/widgets.dart';
import '../providers/settings_notifier.dart';
import '../providers/settings_provider.dart';
import '../types/types.dart';
import '../types/types_l10n.dart';
import '../widgets/more_settings_redirect_card.dart';
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
        SettingsCard(
          title: 'Video player engine',
          subtitle: 'App restart is required for the change to take effect',
          entries: [
            SettingsCardEntry(
              title: 'Default',
              value: VideoPlayerEngine.auto.name,
              groupValue: settings.videoPlayerEngine.name,
              subtitle:
                  'Works well with most devices, may have issues with some video formats or older devices.',
              onSelected: (value) {
                notifer.updateSettings(
                  settings.copyWith(
                    videoPlayerEngine: VideoPlayerEngine.auto,
                  ),
                );
              },
            ),
            SettingsCardEntry(
              title: 'MDK',
              value: VideoPlayerEngine.mdk.name,
              groupValue: settings.videoPlayerEngine.name,
              subtitle:
                  'Experimental, better performance for certain video formats, may cause crashes. Use at your own risk.',
              onSelected: (value) {
                notifer.updateSettings(
                  settings.copyWith(
                    videoPlayerEngine: VideoPlayerEngine.mdk,
                  ),
                );
              },
            ),
          ],
        ),
        BooruConfigMoreSettingsRedirectCard.imageViewer(
          extraActions: [
            RedirectAction(
              label: 'settings.accessibility.accessibility'.tr(),
              onPressed: () {
                context.push(
                  Uri(
                    path: '/settings',
                    queryParameters: {
                      'initial': 'accessibility',
                    },
                  ).toString(),
                );
              },
            ),
          ],
        ),
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

class SettingsCardEntry extends StatelessWidget {
  const SettingsCardEntry({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onSelected,
    super.key,
  });

  final String value;
  final String groupValue;
  final String title;
  final String subtitle;
  final void Function(String? value) onSelected;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
      subtitle: Text(subtitle),
      title: Text(title),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    required this.entries,
    super.key,
    this.subtitle,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final List<Widget> entries;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            vertical: 8,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: entry,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
