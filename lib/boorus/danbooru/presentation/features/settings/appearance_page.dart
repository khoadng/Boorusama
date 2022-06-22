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

class _AppearancePageState extends State<AppearancePage> {
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
            ],
          ));
        },
      ),
    );
  }
}
