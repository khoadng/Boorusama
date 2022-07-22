// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'settings_options.dart';
import 'settings_tile.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_icon.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({
    Key? key,
  }) : super(key: key);

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

String _themeModeToString(ThemeMode theme) {
  switch (theme) {
    case ThemeMode.dark:
      return 'settings.theme.dark';
    case ThemeMode.amoledDark:
      return 'settings.theme.amoled_dark';
    default:
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
    default:
      return 'settings.image_grid.image_quality.automatic';
  }
}

String _gridSizeToString(GridSize size) {
  switch (size) {
    case GridSize.large:
      return 'settings.image_grid.grid_size.large';
    case GridSize.small:
      return 'settings.image_grid.grid_size.small';
    default:
      return 'settings.image_grid.grid_size.medium';
  }
}

String _actionBarDisplayBehaviorToString(ActionBarDisplayBehavior behavior) {
  switch (behavior) {
    case ActionBarDisplayBehavior.staticAtBottom:
      return 'settings.image_detail.action_bar_display_behavior.static_at_bottom';
    default:
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
      final settings = await context.read<ISettingRepository>().load();
      _spacingSliderValue.value = settings.imageGridSpacing;
      _borderRadiusSliderValue.value = settings.imageBorderRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('settings.appearance').tr(),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              primary: false,
              children: [
                SettingsHeader(label: 'settings.general'.tr()),
                SettingsTile(
                  leading: const SettingsIcon(FontAwesomeIcons.paintbrush),
                  title: const Text('settings.theme.theme').tr(),
                  selectedOption:
                      _themeModeToString(state.settings.themeMode).tr(),
                  onTap: () => showRadioOptionsModalBottomSheet<ThemeMode>(
                    context: context,
                    items: [...ThemeMode.values]..remove(ThemeMode.system),
                    titleBuilder: (item) => Text(_themeModeToString(item)).tr(),
                    groupValue: state.settings.themeMode,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .update(state.settings.copyWith(themeMode: value)),
                  ),
                ),
                const Divider(thickness: 1),
                SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
                _buildPreview(context, state),
                SettingsTile(
                  leading: const SettingsIcon(FontAwesomeIcons.tableCells),
                  title: const Text('settings.image_grid.grid_size.grid_size')
                      .tr(),
                  selectedOption:
                      _gridSizeToString(state.settings.gridSize).tr(),
                  onTap: () => showRadioOptionsModalBottomSheet<GridSize>(
                    context: context,
                    items: GridSize.values,
                    titleBuilder: (item) => Text(_gridSizeToString(item)).tr(),
                    groupValue: state.settings.gridSize,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .update(state.settings.copyWith(gridSize: value)),
                  ),
                ),
                SettingsTile(
                  leading: const SettingsIcon(FontAwesomeIcons.images),
                  title: const Text(
                          'settings.image_grid.image_quality.image_quality')
                      .tr(),
                  selectedOption:
                      _imageQualityToString(state.settings.imageQuality).tr(),
                  onTap: () => showRadioOptionsModalBottomSheet<ImageQuality>(
                    context: context,
                    items: [...ImageQuality.values]
                      ..remove(ImageQuality.original),
                    titleBuilder: (item) =>
                        Text(_imageQualityToString(item)).tr(),
                    subtitleBuilder: (item) => item == ImageQuality.high
                        ? Text(
                            'settings.image_grid.image_quality.high_quality_notice',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ).tr()
                        : null,
                    groupValue: state.settings.imageQuality,
                    onChanged: (value) => context
                        .read<SettingsCubit>()
                        .update(state.settings.copyWith(imageQuality: value)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text('settings.image_grid.spacing').tr(),
                ),
                _buildSpacingSlider(state),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text('settings.image_grid.corner_radius').tr(),
                ),
                _buildBorderRadiusSlider(state),
                const Divider(thickness: 1),
                SettingsHeader(
                    label: 'settings.image_viewer.image_viewer'.tr()),
                ListTile(
                  leading: const SettingsIcon(FontAwesomeIcons.image),
                  title: const Text('settings.image_viewer.full_res_as_default')
                      .tr(),
                  subtitle: state.settings.imageQualityInFullView ==
                          ImageQuality.original
                      ? const Text('settings.image_viewer.full_res_notice').tr()
                      : null,
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: state.settings.imageQualityInFullView ==
                          ImageQuality.original,
                      onChanged: (value) {
                        context.read<SettingsCubit>().update(state.settings
                            .copyWith(
                                imageQualityInFullView: value
                                    ? ImageQuality.original
                                    : ImageQuality.automatic));
                      }),
                ),
                const Divider(thickness: 1),
                SettingsHeader(
                    label: 'settings.image_detail.image_detail'.tr()),
                SettingsTile(
                  leading: const SettingsIcon(FontAwesomeIcons.xmarksLines),
                  title: const Text(
                          'settings.image_detail.action_bar_display_behavior.action_bar_display_behavior')
                      .tr(),
                  selectedOption: _actionBarDisplayBehaviorToString(
                          state.settings.actionBarDisplayBehavior)
                      .tr(),
                  onTap: () => showRadioOptionsModalBottomSheet<
                      ActionBarDisplayBehavior>(
                    context: context,
                    items: ActionBarDisplayBehavior.values,
                    titleBuilder: (item) =>
                        Text(_actionBarDisplayBehaviorToString(item)).tr(),
                    groupValue: state.settings.actionBarDisplayBehavior,
                    onChanged: (value) => context.read<SettingsCubit>().update(
                        state.settings
                            .copyWith(actionBarDisplayBehavior: value)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBorderRadiusSlider(SettingsState state) {
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
              .update(state.settings.copyWith(imageBorderRadius: value)),
          onChanged: (value) => _borderRadiusSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildSpacingSlider(SettingsState state) {
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
              .update(state.settings.copyWith(imageGridSpacing: value)),
          onChanged: (value) => _spacingSliderValue.value = value,
        );
      },
    );
  }

  Widget _buildPreview(BuildContext context, SettingsState state) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: size.width / 3,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).backgroundColor,
        ),
        height: size.height * 0.25,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder<double>(
            valueListenable: _spacingSliderValue,
            builder: (context, value, _) => GridView.builder(
                primary: false,
                itemCount: 100,
                gridDelegate: gridSizeToGridDelegate(
                  size: state.settings.gridSize,
                  spacing: value,
                  screenWidth: size.width,
                ),
                itemBuilder: (context, index) {
                  return ValueListenableBuilder<double>(
                    valueListenable: _borderRadiusSliderValue,
                    builder: (context, value, _) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(value),
                      ),
                      child: const Center(
                        child: SettingsIcon(FontAwesomeIcons.image),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
