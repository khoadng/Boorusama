// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../videos/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../routes.dart';
import '../../types/settings.dart';
import '../../types/types.dart';
import '../../types/types_l10n.dart';
import '../../widgets/settings_header.dart';
import '../../widgets/settings_radio_card.dart';
import '../../widgets/settings_tile.dart';

class ImageViewerSettingsSection extends ConsumerWidget {
  const ImageViewerSettingsSection({
    required this.viewer,
    required this.onUpdate,
    super.key,
  });

  final ImageViewerSettings viewer;
  final void Function(ImageViewerSettings) onUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsHeader(label: context.t.settings.general),
        SettingsTile(
          title: Text(
            context.t.settings.image_details.ui_overlay.ui_overlay,
          ),
          selectedOption: viewer.postDetailsOverlayInitialState,
          items: PostDetailsOverlayInitialState.values,
          onChanged: (value) => onUpdate(
            viewer.copyWith(postDetailsOverlayInitialState: value),
          ),
          optionBuilder: (value) => Text(value.localize(context)),
        ),
        SettingsRadioCard(
          title: context.t.settings.image_viewer.swipe_mode,
          subtitle: context.t.settings.image_viewer.swipe_mode_disclaimer,
          entries: [
            SettingsRadioCardEntry(
              title: context.t.settings.image_viewer.swipe_modes.horizontal,
              value: PostDetailsSwipeMode.horizontal.name,
              groupValue: viewer.swipeMode.name,
              subtitle: context
                  .t
                  .settings
                  .image_viewer
                  .swipe_modes
                  .horizontal_description,
              onSelected: (value) {
                onUpdate(
                  viewer.copyWith(swipeMode: PostDetailsSwipeMode.horizontal),
                );
              },
            ),
            SettingsRadioCardEntry(
              title: context.t.settings.image_viewer.swipe_modes.vertical,
              value: PostDetailsSwipeMode.vertical.name,
              groupValue: viewer.swipeMode.name,
              subtitle: context
                  .t
                  .settings
                  .image_viewer
                  .swipe_modes
                  .vertical_description,
              onSelected: (value) {
                onUpdate(
                  viewer.copyWith(swipeMode: PostDetailsSwipeMode.vertical),
                );
              },
            ),
          ],
        ),
        const Divider(thickness: 1),
        SettingsHeader(label: context.t.settings.image_viewer.slideshow),
        SettingsTile(
          title: Text(context.t.settings.image_viewer.slideshow_mode),
          selectedOption: viewer.slideshowDirection,
          items: SlideshowDirection.values,
          onChanged: (value) => onUpdate(
            viewer.copyWith(slideshowDirection: value),
          ),
          optionBuilder: (value) => Text(value.localize(context)),
        ),
        SettingsTile(
          title: Text(context.t.settings.image_viewer.slideshow_interval),
          subtitle: Text(
            context.t.settings.image_viewer.slideshow_interval_explanation,
          ),
          selectedOption: viewer.slideshowInterval,
          items: getSlideShowIntervalPossibleValue(),
          onChanged: (newValue) => onUpdate(
            viewer.copyWith(slideshowInterval: newValue),
          ),
          optionBuilder: (value) => Text(
            context.t.time.counters.second(
              n: value < 1 ? value : value.toInt(),
            ),
          ),
        ),
        BooruSwitchListTile(
          title: Text(context.t.settings.image_viewer.slideshow_skip),
          value: viewer.skipSlideshowTransition,
          onChanged: (value) => onUpdate(
            viewer.copyWith(
              slideshowTransitionType: value
                  ? SlideshowTransitionType.none
                  : SlideshowTransitionType.natural,
            ),
          ),
        ),
        const Divider(thickness: 1),
        SettingsHeader(
          label: context.t.settings.image_viewer.video_section_title,
        ),
        SettingsNavigationTile(
          title: context.t.settings.image_viewer.video.video_player_engine,
          value: viewer.videoPlayerEngine,
          valueBuilder: (engine) => VideoEngineUtils.getUnderlyingEngineName(
            engine,
            platform: Theme.of(context).platform,
            context: context,
          ),
          onTap: () {
            showBooruModalBottomSheet(
              context: context,
              builder: (context) => _VideoEngineSelectorSheet(
                currentEngine: viewer.videoPlayerEngine,
                onChanged: (engine) => onUpdate(
                  viewer.copyWith(videoPlayerEngine: engine),
                ),
              ),
            );
          },
        ),
        BooruSwitchListTile(
          title: Text(context.t.settings.image_viewer.mute_video),
          value: viewer.muteAudioByDefault,
          onChanged: (value) => onUpdate(
            viewer.copyWith(
              videoAudioDefaultState: value
                  ? VideoAudioDefaultState.mute
                  : VideoAudioDefaultState.unmute,
            ),
          ),
        ),
        BooruSwitchListTile(
          title: Text(context.t.settings.image_viewer.enable_video_cache),
          subtitle: Text(
            context.t.settings.image_viewer.enable_video_cache_description,
          ),
          value: viewer.enableVideoCache,
          onChanged: (value) => onUpdate(
            viewer.copyWith(enableVideoCache: value),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
          ),
          onPressed: () {
            openDataAndStoragePage(ref);
          },
          child: Text(context.t.settings.image_viewer.manage_cache),
        ),
      ],
    );
  }
}

class _VideoEngineSelectorSheet extends ConsumerWidget {
  const _VideoEngineSelectorSheet({
    required this.currentEngine,
    required this.onChanged,
  });

  final VideoPlayerEngine currentEngine;
  final void Function(VideoPlayerEngine) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = Theme.of(context).platform;

    return SettingsSelectionSheet(
      title: context.t.settings.image_viewer.video.video_player_engine,
      value: currentEngine,
      items: VideoPlayerEngine.getSupportedEnginesForPlatform(platform),
      itemBuilder: (engine) => VideoEngineUtils.getUnderlyingEngineName(
        engine,
        platform: platform,
        context: context,
      ),
      subtitleBuilder: (engine) => switch (engine) {
        VideoPlayerEngine.auto =>
          context.t.settings.image_viewer.video.engine.auto_description,
        VideoPlayerEngine.videoPlayerPlugin =>
          context.t.settings.image_viewer.video.engine.default_description,
        VideoPlayerEngine.mdk =>
          context.t.settings.image_viewer.video.engine.mdk_description,
        VideoPlayerEngine.mpv =>
          context.t.settings.image_viewer.video.engine.mpv_description,
        VideoPlayerEngine.webview =>
          context.t.settings.image_viewer.video.engine.webview_description,
      },
      onChanged: onChanged,
    );
  }
}

List<double> getSlideShowIntervalPossibleValue() => [
  0.1,
  0.25,
  0.5,
  ...[for (var i = 1; i <= 30; i += 1) i.toDouble()],
];
