// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

String _themeModeToString(ThemeMode theme) {
  switch (theme) {
    case ThemeMode.dark:
      return 'settings.theme.dark';
    case ThemeMode.system:
    case ThemeMode.amoledDark:
      return 'settings.theme.amoled_dark';
    case ThemeMode.light:
      return 'settings.theme.light';
  }
}

String _imageQualityToString(ImageQuality quality) {
  switch (quality) {
    case ImageQuality.high:
      return 'settings.image_grid.image_quality.high';
    case ImageQuality.low:
      return 'settings.image_grid.image_quality.low';
    case ImageQuality.original:
      return 'settings.image_grid.image_quality.original';
    case ImageQuality.automatic:
      return 'settings.image_grid.image_quality.automatic';
  }
}

String _gridSizeToString(GridSize size) {
  switch (size) {
    case GridSize.large:
      return 'settings.image_grid.grid_size.large';
    case GridSize.small:
      return 'settings.image_grid.grid_size.small';
    case GridSize.normal:
      return 'settings.image_grid.grid_size.medium';
  }
}

String _imageListToString(ImageListType imageListType) {
  switch (imageListType) {
    case ImageListType.standard:
      return 'settings.image_list.standard';
    case ImageListType.masonry:
      return 'settings.image_list.masonry';
  }
}

class _AppearancePageState extends ConsumerState<AppearancePage>
    with SettingsRepositoryMixin {
  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);

  @override
  SettingsRepository get settingsRepository =>
      context.read<SettingsRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = await getOrDefault();
      _spacingSliderValue.value = settings.imageGridSpacing;
      _borderRadiusSliderValue.value = settings.imageBorderRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.appearance').tr(),
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
                  context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                        settings.copyWith(themeMode: value),
                        ref,
                      ),
              optionBuilder: (value) => Text(_themeModeToString(value).tr()),
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
            SettingsTile<GridSize>(
              title: const Text('settings.image_grid.grid_size.grid_size').tr(),
              selectedOption: settings.gridSize,
              items: GridSize.values,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                        settings.copyWith(gridSize: value),
                        ref,
                      ),
              optionBuilder: (value) => Text(_gridSizeToString(value).tr()),
            ),
            SettingsTile<ImageListType>(
              title: const Text('settings.image_list.image_list').tr(),
              selectedOption: settings.imageListType,
              items: ImageListType.values,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                        settings.copyWith(imageListType: value),
                        ref,
                      ),
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
                  context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                        settings.copyWith(imageQuality: value),
                        ref,
                      ),
              optionBuilder: (value) => Text(_imageQualityToString(value)).tr(),
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
              context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                    settings.copyWith(imageBorderRadius: value),
                    ref,
                  ),
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
              context.read<SettingsCubit>().updateAndSyncWithRiverpod(
                    settings.copyWith(imageGridSpacing: value),
                    ref,
                  ),
          onChanged: (value) => _spacingSliderValue.value = value,
        );
      },
    );
  }
}
