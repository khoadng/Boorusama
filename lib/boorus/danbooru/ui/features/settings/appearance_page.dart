// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/setting_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'settings_tile.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_icon.dart';

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
      final settings = await context.read<SettingRepository>().load();
      _spacingSliderValue.value = settings.imageGridSpacing;
      _borderRadiusSliderValue.value = settings.imageBorderRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
          ? AppBar(
              title: const Text('settings.appearance').tr(),
            )
          : null,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              primary: false,
              children: [
                SettingsHeader(label: 'settings.general'.tr()),
                SettingsTile<ThemeMode>(
                  title: const Text('settings.theme.theme').tr(),
                  selectedOption: state.settings.themeMode,
                  items: [...ThemeMode.values]..remove(ThemeMode.system),
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .update(state.settings.copyWith(themeMode: value)),
                  optionBuilder: (value) =>
                      Text(_themeModeToString(value).tr()),
                ),
                const Divider(thickness: 1),
                SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
                _buildPreview(context, state),
                SettingsTile<GridSize>(
                  title: const Text('settings.image_grid.grid_size.grid_size')
                      .tr(),
                  selectedOption: state.settings.gridSize,
                  items: GridSize.values,
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .update(state.settings.copyWith(gridSize: value)),
                  optionBuilder: (value) => Text(_gridSizeToString(value).tr()),
                ),
                SettingsTile<ImageQuality>(
                  title: const Text(
                    'settings.image_grid.image_quality.image_quality',
                  ).tr(),
                  subtitle: state.settings.imageQuality == ImageQuality.high
                      ? Text(
                          'settings.image_grid.image_quality.high_quality_notice',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ).tr()
                      : null,
                  selectedOption: state.settings.imageQuality,
                  items: [...ImageQuality.values]
                    ..remove(ImageQuality.original),
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .update(state.settings.copyWith(imageQuality: value)),
                  optionBuilder: (value) =>
                      Text(_imageQualityToString(value)).tr(),
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
                  label: 'settings.image_viewer.image_viewer'.tr(),
                ),
                ListTile(
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
                      context
                          .read<SettingsCubit>()
                          .update(state.settings.copyWith(
                            imageQualityInFullView: value
                                ? ImageQuality.original
                                : ImageQuality.automatic,
                          ));
                    },
                  ),
                ),
                const Divider(thickness: 1),
                SettingsHeader(
                  label: 'settings.image_detail.image_detail'.tr(),
                ),
                SettingsTile<ActionBarDisplayBehavior>(
                  title: const Text(
                    'settings.image_detail.action_bar_display_behavior.action_bar_display_behavior',
                  ).tr(),
                  selectedOption: state.settings.actionBarDisplayBehavior,
                  onChanged: (value) => context.read<SettingsCubit>().update(
                        state.settings
                            .copyWith(actionBarDisplayBehavior: value),
                      ),
                  items: ActionBarDisplayBehavior.values,
                  optionBuilder: (value) =>
                      Text(_actionBarDisplayBehaviorToString(value)).tr(),
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

  SliverGridDelegate _gridSizeToGridDelegate(
    ScreenSize screenSize,
    GridSize size, {
    double spacing = 2,
  }) {
    if (size == GridSize.large) return _largeGrid(spacing / 2, screenSize);
    if (size == GridSize.small) return _smallGrid(spacing / 2, screenSize);

    return _normalGrid(spacing / 2, screenSize);
  }

  Widget _buildPreview(BuildContext context, SettingsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      width: 150,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Theme.of(context).backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder<double>(
          valueListenable: _spacingSliderValue,
          builder: (context, value, _) => GridView.builder(
            itemCount: 100,
            gridDelegate: _gridSizeToGridDelegate(
              Screen.of(context).size,
              state.settings.gridSize,
              spacing: value,
            ),
            itemBuilder: (context, index) {
              return ValueListenableBuilder<double>(
                valueListenable: _borderRadiusSliderValue,
                builder: (context, value, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(value),
                  ),
                  child: const Center(
                    child: SettingsIcon(FontAwesomeIcons.image),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

SliverGridDelegate _normalGrid(
  double spacing,
  ScreenSize size,
) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: displaySizeToGridCountWeight(size) * 2,
      childAspectRatio: size != ScreenSize.small ? 0.9 : 0.65,
    );

SliverGridDelegate _smallGrid(
  double spacing,
  ScreenSize size,
) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: displaySizeToGridCountWeight(size) * 3,
    );

SliverGridDelegate _largeGrid(
  double spacing,
  ScreenSize size,
) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: displaySizeToGridCountWeight(size),
      childAspectRatio: 0.65,
    );
