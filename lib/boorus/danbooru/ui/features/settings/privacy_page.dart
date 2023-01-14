// Flutter imports:
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
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
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.privacy.privacy').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(children: [
          ListTile(
            title: const Text('settings.privacy.send_error_data_notice').tr(),
            trailing: Switch(
              activeColor: Theme.of(context).colorScheme.primary,
              value:
                  settings.dataCollectingStatus == DataCollectingStatus.allow,
              onChanged: (value) {
                context.read<SettingsCubit>().update(settings.copyWith(
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
  }
}
