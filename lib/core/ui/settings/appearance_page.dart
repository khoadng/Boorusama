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
import 'widgets/settings_header.dart';
import 'widgets/settings_tile.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  State<AppearancePage> createState() => _AppearancePageState();
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

String _detailsDisplayToString(DetailsDisplay details) {
  switch (details) {
    case DetailsDisplay.imageFocus:
      return 'settings.details_style.image_focused';
    case DetailsDisplay.postFocus:
      return 'settings.details_style.post_focused';
  }
}

String _actionBarDisplayBehaviorToString(ActionBarDisplayBehavior behavior) {
  switch (behavior) {
    case ActionBarDisplayBehavior.staticAtBottom:
      return 'settings.image_detail.action_bar_display_behavior.static_at_bottom';
    case ActionBarDisplayBehavior.scrolling:
      return 'settings.image_detail.action_bar_display_behavior.scrolling';
  }
}

class _AppearancePageState extends State<AppearancePage> {
  late final ValueNotifier<double> _spacingSliderValue = ValueNotifier(0);
  late final ValueNotifier<double> _borderRadiusSliderValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings =
          await context.read<SettingsRepository>().load().run().then(
                (value) => value.fold(
                  (l) => Settings.defaultSettings,
                  (r) => r,
                ),
              );
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
              onChanged: (value) => context
                  .read<SettingsCubit>()
                  .update(settings.copyWith(themeMode: value)),
              optionBuilder: (value) => Text(_themeModeToString(value).tr()),
            ),
            const Divider(thickness: 1),
            SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
            SettingsTile<GridSize>(
              title: const Text('settings.image_grid.grid_size.grid_size').tr(),
              selectedOption: settings.gridSize,
              items: GridSize.values,
              onChanged: (value) => context
                  .read<SettingsCubit>()
                  .update(settings.copyWith(gridSize: value)),
              optionBuilder: (value) => Text(_gridSizeToString(value).tr()),
            ),
            SettingsTile<ImageListType>(
              title: const Text('settings.image_list.image_list').tr(),
              selectedOption: settings.imageListType,
              items: ImageListType.values,
              onChanged: (value) => context
                  .read<SettingsCubit>()
                  .update(settings.copyWith(imageListType: value)),
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
              onChanged: (value) => context
                  .read<SettingsCubit>()
                  .update(settings.copyWith(imageQuality: value)),
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

            const Divider(thickness: 1),
            // SettingsHeader(
            //   label: 'settings.image_viewer.image_viewer'.tr(),
            // ),
            // ListTile(
            //   title: const Text('settings.image_viewer.full_res_as_default')
            //       .tr(),
            //   subtitle: state.settings.imageQualityInFullView ==
            //           ImageQuality.original
            //       ? const Text('settings.image_viewer.full_res_notice').tr()
            //       : null,
            //   trailing: Switch(
            //     activeColor: Theme.of(context).colorScheme.primary,
            //     value: state.settings.imageQualityInFullView ==
            //         ImageQuality.original,
            //     onChanged: (value) {
            //       context
            //           .read<SettingsCubit>()
            //           .update(state.settings.copyWith(
            //             imageQualityInFullView: value
            //                 ? ImageQuality.original
            //                 : ImageQuality.automatic,
            //           ));
            //     },
            //   ),
            // ),
            // const Divider(thickness: 1),
            SettingsHeader(
              label: 'settings.image_detail.image_detail'.tr(),
            ),
            SettingsTile<ActionBarDisplayBehavior>(
              title: const Text(
                'settings.image_detail.action_bar_display_behavior.action_bar_display_behavior',
              ).tr(),
              selectedOption: settings.actionBarDisplayBehavior,
              onChanged: (value) => context.read<SettingsCubit>().update(
                    settings.copyWith(actionBarDisplayBehavior: value),
                  ),
              items: ActionBarDisplayBehavior.values,
              optionBuilder: (value) =>
                  Text(_actionBarDisplayBehaviorToString(value)).tr(),
            ),
            SettingsTile<DetailsDisplay>(
              title: const Text('settings.details_style.details_style').tr(),
              selectedOption: settings.detailsDisplay,
              items: DetailsDisplay.values,
              onChanged: (value) => context
                  .read<SettingsCubit>()
                  .update(settings.copyWith(detailsDisplay: value)),
              optionBuilder: (value) =>
                  Text(_detailsDisplayToString(value)).tr(),
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
          onChangeEnd: (value) => context
              .read<SettingsCubit>()
              .update(settings.copyWith(imageBorderRadius: value)),
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
          onChangeEnd: (value) => context
              .read<SettingsCubit>()
              .update(settings.copyWith(imageGridSpacing: value)),
          onChanged: (value) => _spacingSliderValue.value = value,
        );
      },
    );
  }
}
