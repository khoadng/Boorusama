// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../create/providers.dart';
import '../edit_booru_config_id.dart';
import 'booru_config_provider.dart';

class UpdateBooruConfigScope extends ConsumerWidget {
  const UpdateBooruConfigScope({
    super.key,
    required this.id,
    required this.child,
  });

  final EditBooruConfigId id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(booruConfigProvider);
    final config = configs.firstWhereOrNull((e) => e.id == id.id);

    if (config == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Config not found'),
        ),
      );
    }

    return ProviderScope(
      overrides: [
        editBooruConfigIdProvider.overrideWithValue(id),
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: child,
    );
  }
}
