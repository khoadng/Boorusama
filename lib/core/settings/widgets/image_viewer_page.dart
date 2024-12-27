// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_header.dart';
import 'package:boorusama/core/settings/widgets/widgets/settings_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'widgets/settings_page_scaffold.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  const ImageViewerPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsPageScaffold(
      hasAppBar: widget.hasAppBar,
      title: const Text('settings.image_viewer.image_viewer').tr(),
      children: [
        SettingsHeader(label: 'settings.general'.tr()),
        SettingsTile(
          title:
              const Text('settings.image_details.ui_overlay.ui_overlay').tr(),
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
          onChanged: (value) =>
              ref.updateSettings(settings.copyWith(slideshowDirection: value)),
          optionBuilder: (value) => Text(value.localize().tr()),
        ),
        SettingsTile(
          title: const Text('Slideshow interval'),
          subtitle: const Text(
              'Value less than 1 second will automatically skip transition'),
          selectedOption: settings.slideshowInterval,
          items: getSlideShowIntervalPossibleValue(),
          onChanged: (newValue) {
            ref.updateSettings(settings.copyWith(slideshowInterval: newValue));
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
                ref.updateSettings(
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
                ref.updateSettings(
                  settings.copyWith(
                    videoPlayerEngine: VideoPlayerEngine.mdk,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
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

class SettingsCardEntry extends StatelessWidget {
  const SettingsCardEntry({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onSelected,
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
            horizontal: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
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
          Container(
            decoration: BoxDecoration(
              //FIXME: change to surfaceContainerLow
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var entry in entries)
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
