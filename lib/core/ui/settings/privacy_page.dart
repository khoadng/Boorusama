// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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
                ref.updateSettings(settings.copyWith(
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
