// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              title: const Text('settings.search').tr(),
            )
          : null,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              primary: false,
              children: [
                SettingsTile<ContentOrganizationCategory>(
                  title:
                      const Text('settings.result_layout.result_layout').tr(),
                  selectedOption: state.settings.contentOrganizationCategory,
                  subtitle: state.settings.contentOrganizationCategory ==
                          ContentOrganizationCategory.infiniteScroll
                      ? const Text(
                          'settings.infinite_scroll_warning',
                        ).tr()
                      : null,
                  items: const [...ContentOrganizationCategory.values],
                  onChanged: (value) => context.read<SettingsCubit>().update(
                        state.settings
                            .copyWith(contentOrganizationCategory: value),
                      ),
                  optionBuilder: (value) => Text(_layoutToString(value)).tr(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _layoutToString(ContentOrganizationCategory category) {
  switch (category) {
    case ContentOrganizationCategory.infiniteScroll:
      return 'settings.result_layout.infinite_scroll';
    case ContentOrganizationCategory.pagination:
      return 'settings.result_layout.pagination';
  }
}
