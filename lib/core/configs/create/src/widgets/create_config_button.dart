// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../config/types.dart';
import '../../../manage/providers.dart';
import '../providers/providers.dart';
import '../types/utils.dart';
import 'booru_config_data_provider.dart';

class CreateOrUpdateBooruConfigButton extends ConsumerWidget {
  const CreateOrUpdateBooruConfigButton({
    required this.canSubmit,
    super.key,
  });

  final bool Function(BooruConfigData config)? canSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);

    final effectiveCanSubmit = canSubmit ?? defaultCanSubmit;

    return editId.isNew
        ? CreateNewBooruConfigButton(canSubmit: effectiveCanSubmit)
        : UpdateBooruConfigButton(canSubmit: effectiveCanSubmit);
  }
}

class CreateNewBooruConfigButton extends ConsumerWidget {
  const CreateNewBooruConfigButton({
    required this.canSubmit,
    super.key,
  });

  final bool Function(BooruConfigData config) canSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);
    final config = ref.watch(initialBooruConfigProvider);

    return BooruConfigDataProvider(
      builder: (data) => TextButton(
        onPressed: canSubmit(data) && data.name.isNotEmpty
            ? () {
                ref
                    .read(booruConfigProvider.notifier)
                    .addOrUpdate(
                      id: editId,
                      newConfig: data,
                      initialData: config,
                    );

                Navigator.of(context).pop();
              }
            : null,
        child: const Text('favorite_groups.create').tr(),
      ),
    );
  }
}

class UpdateBooruConfigButton extends ConsumerWidget {
  const UpdateBooruConfigButton({
    required this.canSubmit,
    super.key,
  });

  final bool Function(BooruConfigData config) canSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);

    return BooruConfigDataProvider(
      builder: (data) => TextButton(
        onPressed: canSubmit(data)
            ? () {
                ref
                    .read(booruConfigProvider.notifier)
                    .addOrUpdate(
                      id: editId,
                      newConfig: data,
                    );

                Navigator.of(context).pop();
              }
            : null,
        child: const Text('Save'),
      ),
    );
  }
}
