// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/booru_config_info_tile.dart';
import 'package:boorusama/boorus/core/provider.dart';
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
