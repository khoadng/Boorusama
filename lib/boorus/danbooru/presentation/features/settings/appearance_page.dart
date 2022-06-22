// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

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

Future<T?> showOptionsModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) =>
    showMaterialModalBottomSheet(
      duration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).backgroundColor,
      context: context,
      builder: builder,
    );

Future<T?> showRadioOptionsModalBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required Widget Function(T item) titleBuilder,
  required T groupValue,
  required void Function(T value) onChanged,
}) =>
    showOptionsModalBottomSheet(
      context: context,
      builder: (context) => SettingsOptions<T>.radio(
        items: items,
        titleBuilder: titleBuilder,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );

class SettingsOptions<T> extends StatelessWidget {
  const SettingsOptions({
    Key? key,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);

  factory SettingsOptions.radio({
    required List<T> items,
    required Widget Function(T item) titleBuilder,
    required T groupValue,
    required void Function(T value) onChanged,
  }) =>
      SettingsOptions<T>(
        items: items,
        itemBuilder: (context, item) => RadioListTile<T>(
          value: item,
          activeColor: Theme.of(context).colorScheme.primary,
          title: titleBuilder(item),
          groupValue: groupValue,
          onChanged: (value) {
            if (value == null) return;
            Navigator.of(context).pop();
            onChanged(value);
          },
        ),
      );

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((e) => itemBuilder(context, e)).toList(),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    Key? key,
    required this.title,
    required this.selectedOption,
    required this.onTap,
    required this.leading,
  }) : super(key: key);

  final Widget title;
  final String selectedOption;
  final VoidCallback onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedOption),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: FaIcon(
              FontAwesomeIcons.angleDown,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
