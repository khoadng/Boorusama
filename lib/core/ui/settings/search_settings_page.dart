// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'widgets/settings_tile.dart';

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
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.search').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            if (isMobilePlatform())
              ListTile(
                title: const Text(
                  'Auto focus search bar when first open search view',
                ),
                trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: settings.autoFocusSearchBar,
                  onChanged: (value) {
                    context.read<SettingsCubit>().update(settings.copyWith(
                          autoFocusSearchBar: value,
                        ));
                  },
                ),
              ),
            SettingsTile<ContentOrganizationCategory>(
              title: const Text('settings.result_layout.result_layout').tr(),
              selectedOption: settings.contentOrganizationCategory,
              subtitle: settings.contentOrganizationCategory ==
                      ContentOrganizationCategory.infiniteScroll
                  ? const Text(
                      'settings.infinite_scroll_warning',
                    ).tr()
                  : null,
              items: const [...ContentOrganizationCategory.values],
              onChanged: (value) => context.read<SettingsCubit>().update(
                    settings.copyWith(contentOrganizationCategory: value),
                  ),
              optionBuilder: (value) => Text(_layoutToString(value)).tr(),
            ),
          ],
        ),
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
