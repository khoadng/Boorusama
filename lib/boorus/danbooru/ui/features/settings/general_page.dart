// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'settings_tile.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
          ? AppBar(
              title: const Text('General'),
            )
          : null,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              primary: false,
              children: [
                SettingsTile<BooruType>(
                  title: const Text('Data source'),
                  selectedOption: state.settings.safeMode
                      ? BooruType.safebooru
                      : BooruType.danbooru,
                  items: [...BooruType.values]
                    ..remove(BooruType.testbooru)
                    ..remove(BooruType.unknown),
                  onChanged: (value) => context.read<SettingsCubit>().update(
                        state.settings
                            .copyWith(safeMode: value == BooruType.safebooru),
                      ),
                  optionBuilder: (value) => Text(value.name.sentenceCase),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
