// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/booru_logo.dart';

class SwitchBooruModal extends StatelessWidget {
  const SwitchBooruModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final configs =
        context.select((ManageBooruBloc bloc) => bloc.state.configs);
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    final booruFactory = context.read<BooruFactory>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Material(
        color: Colors.transparent,
        child: configs != null
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  controller: ModalScrollController.of(context),
                  itemCount: configs.length,
                  itemBuilder: (context, index) {
                    final config = configs[index];
                    final booru = config.createBooruFrom(booruFactory);
                    final isSelected =
                        settings.currentBooruConfigId == config.id;

                    return ListTile(
                      horizontalTitleGap: 0,
                      leading: BooruLogo(booru: booru),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      title: Text(
                        config.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      subtitle: Text(
                        config.login?.isEmpty ?? true
                            ? '<Anonymous>'
                            : config.login ?? 'Unknown',
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        context
                            .read<CurrentBooruBloc>()
                            .add(CurrentBooruChanged(
                              booruConfig: config,
                              settings: settings,
                            ));
                      },
                    );
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
