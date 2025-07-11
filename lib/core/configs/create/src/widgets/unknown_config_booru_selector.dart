// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../widgets/widgets.dart';
import '../providers/internal_providers.dart';

class UnknownConfigBooruSelector extends ConsumerWidget {
  const UnknownConfigBooruSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);
    final engineRegistry = ref.watch(booruEngineRegistryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: ListTile(
        title: Text(context.t.booru.booru_engine_input_label),
        trailing: OptionDropDownButton(
          alignment: AlignmentDirectional.centerStart,
          value: engine,
          onChanged: (value) {
            ref.read(booruEngineProvider.notifier).state = value;
          },
          items: engineRegistry
              .getAllBoorus()
              .map((e) => e.type)
              .where((e) => !e.isSingleSite)
              .sorted((a, b) => a.displayName.compareTo(b.displayName))
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.displayName),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
