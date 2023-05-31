// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'widgets/settings_header.dart';
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

String _themeModeToString(ThemeMode theme) => switch (theme) {
      ThemeMode.dark => 'settings.theme.dark',
      ThemeMode.system || ThemeMode.amoledDark => 'settings.theme.amoled_dark',
      ThemeMode.light => 'settings.theme.light',
    };

String _imageQualityToString(ImageQuality quality) => switch (quality) {
      ImageQuality.high => 'settings.image_grid.image_quality.high',
      ImageQuality.low => 'settings.image_grid.image_quality.low',
      ImageQuality.original => 'settings.image_grid.image_quality.original',
      ImageQuality.automatic => 'settings.image_grid.image_quality.automatic'
    };

String _gridSizeToString(GridSize size) => switch (size) {
      GridSize.large => 'settings.image_grid.grid_size.large',
      GridSize.small => 'settings.image_grid.grid_size.small',
      GridSize.normal => 'settings.image_grid.grid_size.medium'
    };

String _imageListToString(ImageListType imageListType) =>
    switch (imageListType) {
      ImageListType.standard => 'settings.image_list.standard',
      ImageListType.masonry => 'settings.image_list.masonry'
    };

class _AppearancePageState extends ConsumerState<AppearancePage> {
  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _spacingSliderValue.value = settings.imageGridSpacing;
    _borderRadiusSliderValue.value = settings.imageBorderRadius;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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
            SettingsTile<ThemeMode>(
              title: const Text('settings.theme.theme').tr(),
              selectedOption: settings.themeMode,
              items: [...ThemeMode.values]..remove(ThemeMode.system),
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(themeMode: value)),
              optionBuilder: (value) => Text(_themeModeToString(value).tr()),
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
            SettingsTile<GridSize>(
              title: const Text('settings.image_grid.grid_size.grid_size').tr(),
              selectedOption: settings.gridSize,
              items: GridSize.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(gridSize: value)),
              optionBuilder: (value) => Text(_gridSizeToString(value).tr()),
            ),
            SettingsTile<ImageListType>(
              title: const Text('settings.image_list.image_list').tr(),
              selectedOption: settings.imageListType,
              items: ImageListType.values,
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageListType: value)),
              optionBuilder: (value) => Text(_imageListToString(value)).tr(),
            ),
            SettingsTile<ImageQuality>(
              title: const Text(
                'settings.image_grid.image_quality.image_quality',
              ).tr(),
              subtitle: settings.imageQuality == ImageQuality.high
                  ? Text(
                      'settings.image_grid.image_quality.high_quality_notice',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                    ).tr()
                  : null,
              selectedOption: settings.imageQuality,
              items: [...ImageQuality.values]..remove(ImageQuality.original),
              onChanged: (value) =>
                  ref.updateSettings(settings.copyWith(imageQuality: value)),
              optionBuilder: (value) => Text(_imageQualityToString(value)).tr(),
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
              optionBuilder: (value) => Text(_layoutToString(value)).tr(),
            ),
            SwitchListTile.adaptive(
              title: const Text('settings.appearance.show_scores').tr(),
              value: settings.showScoresInGrid,
              onChanged: (value) => ref
                  .updateSettings(settings.copyWith(showScoresInGrid: value)),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('settings.image_grid.spacing').tr(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildSpacingSlider(settings),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('settings.image_grid.corner_radius').tr(),
                  ),
                  _buildBorderRadiusSlider(settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderRadiusSlider(Settings settings) {
    return ValueListenableBuilder<double>(
      valueListenable: _borderRadiusSliderValue,
      builder: (context, value, child) {
        return Slider.adaptive(
          label: value.toInt().toString(),
          divisions: 10,
          max: 10,
          value: value,
          onChangeEnd: (value) =>
              ref.updateSettings(settings.copyWith(imageBorderRadius: value)),
          onChanged: (value) => _borderRadiusSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildSpacingSlider(Settings settings) {
    return ValueListenableBuilder<double>(
      valueListenable: _spacingSliderValue,
      builder: (context, value, child) {
        return Slider.adaptive(
          label: value.toInt().toString(),
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
}

String _layoutToString(PageMode category) => switch (category) {
      PageMode.infinite => 'settings.result_layout.infinite_scroll',
      PageMode.paginated => 'settings.result_layout.pagination'
    };
