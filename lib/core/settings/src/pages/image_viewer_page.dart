// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../configs/config/widgets.dart';
import '../../../router.dart';
import '../../../videos/providers.dart';
import '../../../widgets/widgets.dart';
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
      title: Text(context.t.settings.image_viewer.image_viewer),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsHeader(label: context.t.settings.general),
            SettingsTile(
              title: Text(
                context.t.settings.image_details.ui_overlay.ui_overlay,
              ),
              selectedOption: settings.viewer.postDetailsOverlayInitialState,
              items: PostDetailsOverlayInitialState.values,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  viewer: settings.viewer.copyWith(
                    postDetailsOverlayInitialState: value,
                  ),
                ),
              ),
              optionBuilder: (value) => Text(value.localize(context)),
            ),
            SettingsCard(
              title: context.t.settings.image_viewer.swipe_mode,
              subtitle: context.t.settings.image_viewer.swipe_mode_disclaimer,
              entries: [
                SettingsCardEntry(
                  title: context.t.settings.image_viewer.swipe_modes.horizontal,
                  value: PostDetailsSwipeMode.horizontal.name,
                  groupValue: settings.viewer.swipeMode.name,
                  subtitle: context
                      .t
                      .settings
                      .image_viewer
                      .swipe_modes
                      .horizontal_description,
                  onSelected: (value) {
                    notifer.updateSettings(
                      settings.copyWith(
                        viewer: settings.viewer.copyWith(
                          swipeMode: PostDetailsSwipeMode.horizontal,
                        ),
                      ),
                    );
                  },
                ),
                SettingsCardEntry(
                  title: context.t.settings.image_viewer.swipe_modes.vertical,
                  value: PostDetailsSwipeMode.vertical.name,
                  groupValue: settings.viewer.swipeMode.name,
                  subtitle: context
                      .t
                      .settings
                      .image_viewer
                      .swipe_modes
                      .vertical_description,
                  onSelected: (value) {
                    notifer.updateSettings(
                      settings.copyWith(
                        viewer: settings.viewer.copyWith(
                          swipeMode: PostDetailsSwipeMode.vertical,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: context.t.settings.image_viewer.slideshow),
            SettingsTile(
              title: Text(context.t.settings.image_viewer.slideshow_mode),
              selectedOption: settings.viewer.slideshowDirection,
              items: SlideshowDirection.values,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  viewer: settings.viewer.copyWith(
                    slideshowDirection: value,
                  ),
                ),
              ),
              optionBuilder: (value) => Text(value.localize(context)),
            ),
            SettingsTile(
              title: Text(context.t.settings.image_viewer.slideshow_interval),
              subtitle: Text(
                context.t.settings.image_viewer.slideshow_interval_explanation,
              ),
              selectedOption: settings.viewer.slideshowInterval,
              items: getSlideShowIntervalPossibleValue(),
              onChanged: (newValue) {
                notifer.updateSettings(
                  settings.copyWith(
                    viewer: settings.viewer.copyWith(
                      slideshowInterval: newValue,
                    ),
                  ),
                );
              },
              optionBuilder: (value) => Text(
                context.t.time.counters.second(
                  n: value < 1 ? value : value.toInt(),
                ),
              ),
            ),
            BooruSwitchListTile(
              title: Text(context.t.settings.image_viewer.slideshow_skip),
              value: settings.viewer.skipSlideshowTransition,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  viewer: settings.viewer.copyWith(
                    slideshowTransitionType: value
                        ? SlideshowTransitionType.none
                        : SlideshowTransitionType.natural,
                  ),
                ),
              ),
            ),
            const Divider(thickness: 1),
            SettingsHeader(
              label: context.t.settings.image_viewer.video_section_title,
            ),
            BooruSwitchListTile(
              title: Text(context.t.settings.image_viewer.mute_video),
              value: settings.viewer.muteAudioByDefault,
              onChanged: (value) => notifer.updateSettings(
                settings.copyWith(
                  viewer: settings.viewer.copyWith(
                    videoAudioDefaultState: value
                        ? VideoAudioDefaultState.mute
                        : VideoAudioDefaultState.unmute,
                  ),
                ),
              ),
            ),
          ],
        ),
        SettingsNavigationTile(
          title: context.t.settings.image_viewer.video.video_player_engine,
          value: settings.viewer.videoPlayerEngine,
          valueBuilder: (engine) => VideoEngineUtils.getUnderlyingEngineName(
            engine,
            platform: Theme.of(context).platform,
            context: context,
          ),
          onTap: () {
            showBooruModalBottomSheet(
              context: context,
              builder: (context) => const _VideoEngineSelectorSheet(),
            );
          },
        ),
        BooruConfigMoreSettingsRedirectCard.imageViewer(
          extraActions: [
            RedirectAction(
              label: context.t.settings.accessibility.accessibility,
              onPressed: () {
                ref.router.push(
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

class _VideoEngineSelectorSheet extends ConsumerWidget {
  const _VideoEngineSelectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifer = ref.watch(settingsNotifierProvider.notifier);

    return SettingsSelectionSheet(
      title: context.t.settings.image_viewer.video.video_player_engine,
      value: settings.viewer.videoPlayerEngine,
      items: VideoPlayerEngine.values,
      itemBuilder: (engine) => VideoEngineUtils.getUnderlyingEngineName(
        engine,
        platform: Theme.of(context).platform,
        context: context,
      ),
      subtitleBuilder: (engine) => switch (engine) {
        VideoPlayerEngine.auto =>
          context.t.settings.image_viewer.video.engine.auto_description,
        VideoPlayerEngine.videoPlayerPlugin =>
          context.t.settings.image_viewer.video.engine.default_description,
        VideoPlayerEngine.mdk =>
          context.t.settings.image_viewer.video.engine.mdk_description,
        VideoPlayerEngine.webview =>
          context.t.settings.image_viewer.video.engine.webview_description,
      },
      onChanged: (value) => notifer.updateSettings(
        settings.copyWith(
          viewer: settings.viewer.copyWith(
            videoPlayerEngine: value,
          ),
        ),
      ),
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
      padding:
          padding ??
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
