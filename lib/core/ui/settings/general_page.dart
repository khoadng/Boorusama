// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'widgets/settings_tile.dart';

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
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.general').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsTile<BooruType>(
              title: const Text('settings.general_data_source').tr(),
              selectedOption:
                  settings.safeMode ? BooruType.safebooru : BooruType.danbooru,
              items: [...BooruType.values]
                ..remove(BooruType.testbooru)
                ..remove(BooruType.unknown),
              onChanged: (value) => context.read<SettingsCubit>().update(
                    settings.copyWith(safeMode: value == BooruType.safebooru),
                  ),
              optionBuilder: (value) => Text(value.name.sentenceCase),
            ),
          ],
        ),
      ),
    );
  }
}
