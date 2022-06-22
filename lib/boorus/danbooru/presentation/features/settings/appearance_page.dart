// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/settings.dart';
import 'package:boorusama/core/presentation/grid_size.dart';
import 'settings_options.dart';
import 'settings_tile.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({
    Key? key,
    required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

SliverGridDelegate _normalGrid(double spacing) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: 2,
      childAspectRatio: 0.65,
    );

SliverGridDelegate _smallGrid(double spacing) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: 3,
    );

SliverGridDelegate _largeGrid(double spacing) =>
    SliverGridDelegateWithFixedCrossAxisCount(
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      crossAxisCount: 1,
      childAspectRatio: 0.65,
    );
SliverGridDelegate _gridSizeToGridDelegate(
  GridSize size, {
  double spacing = 2,
}) {
  if (size == GridSize.large) return _largeGrid(spacing / 2);
  if (size == GridSize.small) return _smallGrid(spacing / 2);
  return _normalGrid(spacing / 2);
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
        title: Text('settings.appSettings.appearance._string'.tr()),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
              child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: MediaQuery.of(context).size.width / 3,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).backgroundColor,
                  ),
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ValueListenableBuilder<double>(
                      valueListenable: _spacingSliderValue,
                      builder: (context, value, _) => GridView.builder(
                          itemCount: 20,
                          gridDelegate: _gridSizeToGridDelegate(
                            state.settings.gridSize,
                            spacing: value,
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
                                  child: FaIcon(FontAwesomeIcons.image),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ),
              SettingsTile(
                leading: const FaIcon(FontAwesomeIcons.paintbrush),
                title: const Text('Theme'),
                selectedOption: state.settings.themeMode.name.sentenceCase,
                onTap: () => showRadioOptionsModalBottomSheet<ThemeMode>(
                  context: context,
                  items: [...ThemeMode.values]..remove(ThemeMode.system),
                  titleBuilder: (item) => Text(item.name.headerCase),
                  groupValue: state.settings.themeMode,
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .update(state.settings.copyWith(themeMode: value)),
                ),
              ),
              SettingsTile(
                leading: const FaIcon(FontAwesomeIcons.tableCells),
                title: const Text('Grid size'),
                selectedOption: state.settings.gridSize.name.sentenceCase,
                onTap: () => showRadioOptionsModalBottomSheet<GridSize>(
                  context: context,
                  items: GridSize.values,
                  titleBuilder: (item) => Text(item.name.headerCase),
                  groupValue: state.settings.gridSize,
                  onChanged: (value) => context
                      .read<SettingsCubit>()
                      .update(state.settings.copyWith(gridSize: value)),
                ),
              ),
              const Divider(thickness: 1.5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Spacing'),
              ),
              ValueListenableBuilder<double>(
                valueListenable: _spacingSliderValue,
                builder: (context, value, child) {
                  return Slider.adaptive(
                    label: value.toInt().toString(),
                    divisions: 10,
                    max: 10,
                    value: value,
                    onChangeEnd: (value) => context
                        .read<SettingsCubit>()
                        .update(
                            state.settings.copyWith(imageGridSpacing: value)),
                    onChanged: (value) => _spacingSliderValue.value = value,
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Corner radius'),
              ),
              ValueListenableBuilder<double>(
                valueListenable: _borderRadiusSliderValue,
                builder: (context, value, child) {
                  return Slider.adaptive(
                    label: value.toInt().toString(),
                    divisions: 10,
                    max: 10,
                    value: value,
                    onChangeEnd: (value) => context
                        .read<SettingsCubit>()
                        .update(
                            state.settings.copyWith(imageBorderRadius: value)),
                    onChanged: (value) =>
                        _borderRadiusSliderValue.value = value,
                  );
                },
              ),
            ],
          ));
        },
      ),
    );
  }
}
