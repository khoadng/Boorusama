// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_slider_tile.dart';
import 'widgets/settings_tile.dart';

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _paddingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _aspectRatioSliderValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _spacingSliderValue.value = settings.imageGridSpacing;
    _borderRadiusSliderValue.value = settings.imageBorderRadius;
    _paddingSliderValue.value = settings.imageGridPadding;
    _aspectRatioSliderValue.value = settings.imageGridAspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.appearance.appearance').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsHeader(label: 'settings.general'.tr()),
            SettingsTile<AppThemeMode>(
              title: const Text('settings.theme.theme').tr(),
              selectedOption: settings.themeMode,
              items: AppThemeMode.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(themeMode: value)),
              optionBuilder: (value) => Text(value.localize()).tr(),
            ),
            Builder(builder: (context) {
              return SwitchListTile(
                title: const Text('settings.theme.dynamic_color').tr(),
                subtitle: dynamicColorSupported
                    ? !isDesktopPlatform()
                        ? const Text(
                            'settings.theme.dynamic_color_mobile_description',
                          ).tr()
                        : const Text(
                            'settings.theme.dynamic_color_desktop_description',
                          ).tr()
                    : Text(
                        '${!isDesktopPlatform() ? 'settings.theme.dynamic_color_mobile_description'.tr() : 'settings.theme.dynamic_color_desktop_description'.tr()}. ${'settings.theme.dynamic_color_unsupported_description'.tr()}',
                      ),
                value: settings.enableDynamicColoring,
                onChanged: dynamicColorSupported
                    ? (value) => ref.updateSettings(
                        settings.copyWith(enableDynamicColoring: value))
                    : null,
              );
            }),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
            SettingsTile<GridSize>(
              title: const Text('settings.image_grid.grid_size.grid_size').tr(),
              selectedOption: settings.gridSize,
              items: GridSize.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(gridSize: value)),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            SettingsTile<ImageListType>(
              title: const Text('settings.image_list.image_list').tr(),
              selectedOption: settings.imageListType,
              items: ImageListType.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageListType: value)),
              optionBuilder: (value) => Text(value.localize()).tr(),
            ),
            SettingsTile<ImageQuality>(
              title: const Text(
                'settings.image_grid.image_quality.image_quality',
              ).tr(),
              subtitle: settings.imageQuality == ImageQuality.highest
                  ? Text(
                      'settings.image_grid.image_quality.high_quality_notice',
                      style: TextStyle(
                        color: context.theme.hintColor,
                      ),
                    ).tr()
                  : null,
              selectedOption: settings.imageQuality,
              items: [...ImageQuality.values]..remove(ImageQuality.original),
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageQuality: value)),
              optionBuilder: (value) => Text(value.localize()).tr(),
            ),
            SettingsTile<PageMode>(
              title: const Text('settings.result_layout.result_layout').tr(),
              selectedOption: settings.pageMode,
              subtitle: settings.pageMode == PageMode.infinite
                  ? const Text('settings.infinite_scroll_warning').tr()
                  : null,
              items: const [...PageMode.values],
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(pageMode: value)),
              optionBuilder: (value) => Text(value.localize()).tr(),
            ),
            if (settings.pageMode == PageMode.paginated)
              SettingsTile<PageIndicatorPosition>(
                title:
                    const Text('settings.page_indicator.page_indicator').tr(),
                selectedOption: settings.pageIndicatorPosition,
                items: const [...PageIndicatorPosition.values],
                onChanged: (value) => ref.updateSettings(
                    settings.copyWith(pageIndicatorPosition: value)),
                optionBuilder: (value) => Text(value.localize()).tr(),
              ),
            SwitchListTile(
              title: const Text('settings.appearance.show_scores').tr(),
              value: settings.showScoresInGrid,
              onChanged: (value) => ref
                  .updateSettings(settings.copyWith(showScoresInGrid: value)),
            ),
            SwitchListTile(
              title:
                  const Text('settings.appearance.show_post_list_config_header')
                      .tr(),
              value: settings.showPostListConfigHeader,
              onChanged: (value) =>
                  ref.setPostListConfigHeaderStatus(active: value),
            ),
            SwitchListTile(
              title: const Text('Blur explicit content').tr(),
              value: settings.blurExplicitMedia,
              onChanged: (value) => ref.updateSettings(settings.copyWith(
                  mediaBlurCondition: value
                      ? MediaBlurCondition.explicitOnly
                      : MediaBlurCondition.none)),
            ),
            const SizedBox(height: 4),
            _buildSpacingSlider(settings),
            const SizedBox(height: 10),
            _buildBorderRadiusSlider(settings),
            const SizedBox(height: 10),
            _buildPaddingSlider(settings),
            const SizedBox(height: 10),
            _buildAspectRatioSlider(settings),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.appearance.booru_config'.tr()),
            SettingsTile<BooruConfigSelectorPosition>(
              title:
                  const Text('settings.appearance.booru_config_placement').tr(),
              selectedOption: settings.booruConfigSelectorPosition,
              items: const [...BooruConfigSelectorPosition.values],
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(booruConfigSelectorPosition: value)),
              optionBuilder: (value) => Text(value.localize()),
            ),
            SettingsTile<BooruConfigLabelVisibility>(
              title: const Text('Label').tr(),
              selectedOption: settings.booruConfigLabelVisibility,
              items: const [...BooruConfigLabelVisibility.values],
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(booruConfigLabelVisibility: value)),
              optionBuilder: (value) => Text(value.localize()),
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_details.image_details'.tr()),
            SettingsTile<PostDetailsOverlayInitialState>(
              title: const Text('settings.image_details.ui_overlay.ui_overlay')
                  .tr(),
              selectedOption: settings.postDetailsOverlayInitialState,
              items: PostDetailsOverlayInitialState.values,
              onChanged: (value) => ref.updateSettings(
                  settings.copyWith(postDetailsOverlayInitialState: value)),
              optionBuilder: (value) => Text(value.localize().tr()),
            ),
            SettingsTile(
              title: const Text('Slideshow Interval'),
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
              title: const Text('Skip Slideshow Transition'),
              value: settings.skipSlideshowTransition,
              onChanged: (value) => ref.updateSettings(
                settings.copyWith(
                  slideshowTransitionType: value
                      ? SlideshowTransitionType.none
                      : SlideshowTransitionType.natural,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderRadiusSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _borderRadiusSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.corner_radius',
          divisions: 20,
          max: 20,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageBorderRadius: value)),
          onChanged: (value) => _borderRadiusSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildSpacingSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _spacingSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.spacing',
          divisions: 10,
          max: 10,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageGridSpacing: value)),
          onChanged: (value) => _spacingSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildPaddingSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _paddingSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.padding',
          divisions: 8,
          max: 32,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageGridPadding: value)),
          onChanged: (value) => _paddingSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildAspectRatioSlider(Settings settings) {
    return ValueListenableBuilder(
      valueListenable: _aspectRatioSliderValue,
      builder: (context, value, child) {
        return SettingsSliderTile(
          title: 'settings.image_grid.aspect_ratio',
          divisions: 10,
          max: 1.5,
          min: 0.5,
          value: value,
          onChangeEnd: (value) => ref
              .updateSettings(settings.copyWith(imageGridAspectRatio: value)),
          onChanged: (value) => _aspectRatioSliderValue.value = value,
        );
      },
    );
  }
}

Future<void> openAppearancePage(BuildContext context) {
  return Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const AppearancePage(),
    ),
  );
}
