// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.dataCollectingStatus !=
          current.settings.dataCollectingStatus,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Privacy'),
          ),
          body: SafeArea(
              child: Column(children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Send anonymous data for error logging'),
              trailing: Switch(
                activeColor: Theme.of(context).colorScheme.primary,
                value: state.settings.dataCollectingStatus ==
                    DataCollectingStatus.allow,
                onChanged: (value) {
                  context.read<SettingsCubit>().update(state.settings.copyWith(
                      dataCollectingStatus: value
                          ? DataCollectingStatus.allow
                          : DataCollectingStatus.prohibit));
                },
              ),
            ),
          ])),
        );
      },
    );
  }
}
