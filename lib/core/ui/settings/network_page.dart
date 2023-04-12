import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/core/ui/settings/widgets/settings_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({Key? key}) : super(key: key);

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  @override
  Widget build(BuildContext context) {
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('settings.network').tr(),
      ),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            SettingsTile<DohOptions>(
              title: const Text('settings.network_dns_over_https').tr(),
              selectedOption: settings.selectedDohProvider,
              items: const [...DohOptions.values],
              onChanged: (value) {
                context.read<SettingsCubit>().update(
                      settings.copyWith(selectedDohProvider: value),
                    );
              },
              optionBuilder: (value) => Text(value.name.sentenceCase),
            ),
          ],
        ),
      ),
    );
  }
}
