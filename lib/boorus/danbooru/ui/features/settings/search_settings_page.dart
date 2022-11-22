// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'settings_tile.dart';

class SearchSettingsPage extends StatefulWidget {
  const SearchSettingsPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  State<SearchSettingsPage> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends State<SearchSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hasAppBar
          ? AppBar(
              title: const Text('Search'),
            )
          : null,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              primary: false,
              children: [
                SettingsTile<ContentOrganizationCategory>(
                  title: const Text('Result layout'),
                  selectedOption: state.settings.contentOrganizationCategory,
                  subtitle: state.settings.contentOrganizationCategory ==
                          ContentOrganizationCategory.infiniteScroll
                      ? const Text(
                          'Might crash the app if you scroll for a long time',
                        )
                      : null,
                  items: const [...ContentOrganizationCategory.values],
                  onChanged: (value) => context.read<SettingsCubit>().update(
                        state.settings
                            .copyWith(contentOrganizationCategory: value),
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
