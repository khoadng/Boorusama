// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/domain/settings/settings.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.dataCollectingStatus !=
          current.settings.dataCollectingStatus,
      builder: (context, state) {
        return Scaffold(
          appBar: hasAppBar
              ? AppBar(
                  title: const Text('settings.privacy.privacy').tr(),
                )
              : null,
          body: SafeArea(
            child: Column(children: [
              ListTile(
                title:
                    const Text('settings.privacy.send_error_data_notice').tr(),
                trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: state.settings.dataCollectingStatus ==
                      DataCollectingStatus.allow,
                  onChanged: (value) {
                    context
                        .read<SettingsCubit>()
                        .update(state.settings.copyWith(
                          dataCollectingStatus: value
                              ? DataCollectingStatus.allow
                              : DataCollectingStatus.prohibit,
                        ));
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
