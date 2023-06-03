// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/boorus/booru_config_info_tile.dart';
import 'package:boorusama/router.dart';

class ManageBooruPage extends ConsumerWidget {
  const ManageBooruPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(booruConfigProvider);
    final currentConfig = ref.watch(currentBooruConfigProvider);
    final booruFactory = ref.watch(booruFactoryProvider);

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/boorus/add'),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: configs.length,
        itemBuilder: (context, index) {
          final config = configs[index];
          final booru = config.createBooruFrom(booruFactory);
          final isCurrent = currentConfig.id == config.id;

          return BooruConfigInfoTile(
            booru: booru,
            config: config,
            isCurrent: isCurrent,
            trailing: !isCurrent
                ? IconButton(
                    onPressed: () =>
                        ref.read(booruConfigProvider.notifier).delete(config),
                    icon: const Icon(Icons.close),
                  )
                : null,
            onTap: () => context.go('/boorus/${config.id}/update'),
          );
        },
      ),
    );
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
