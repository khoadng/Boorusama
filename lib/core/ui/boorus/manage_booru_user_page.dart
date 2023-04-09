// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/boorus/add_booru_page.dart';
import 'package:boorusama/core/ui/boorus/booru_config_info_tile.dart';

class ManageBooruPage extends StatelessWidget {
  const ManageBooruPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final configs =
        context.select((ManageBooruBloc bloc) => bloc.state.configs);

    final currentConfig =
        context.select((CurrentBooruBloc bloc) => bloc.state.booruConfig);

    final booruFactory = context.read<BooruFactory>();

    return configs != null
        ? Scaffold(
            appBar: AppBar(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => goToAddBooruPage(context),
              child: const Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: configs.length,
              itemBuilder: (context, index) {
                final config = configs[index];
                final booru = config.createBooruFrom(booruFactory);
                final isCurrent = currentConfig?.id == config.id;

                return BooruConfigInfoTile(
                  booru: booru,
                  config: config,
                  isCurrent: isCurrent,
                  trailing: !isCurrent
                      ? IconButton(
                          onPressed: () => context
                              .read<ManageBooruBloc>()
                              .add(ManageBooruRemoved(
                                user: config,
                                onFailure: print,
                              )),
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  onTap: () => showMaterialModalBottomSheet(
                    context: context,
                    builder: (_) => AddBooruPage.of(
                      context,
                      booruFactory: context.read<BooruFactory>(),
                      initialConfig: config,
                      onSubmit: (newConfig) {
                        context.read<ManageBooruBloc>().add(ManageBooruUpdated(
                              config: newConfig,
                              oldConfig: config,
                              id: config.id,
                            ));
                      },
                    ),
                  ),
                );
              },
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet({
    required this.onSubmit,
  });

  final void Function(String login, String apiKey, BooruType booru) onSubmit;

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  var selectedBooru = BooruType.unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: loginController,
          ),
          TextField(
            controller: apiKeyController,
          ),
          DropdownButton<BooruType>(
            value: selectedBooru,
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  selectedBooru = value;
                }
              });
            },
            items: BooruType.values
                .map((e) => DropdownMenuItem<BooruType>(
                      value: e,
                      child: Text(e.name),
                    ))
                .toList(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSubmit.call(
                loginController.text,
                apiKeyController.text,
                selectedBooru,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
