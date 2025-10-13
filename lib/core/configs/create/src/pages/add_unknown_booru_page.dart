// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../config/types.dart';
import '../../widgets.dart';
import '../providers/internal_providers.dart';
import '../providers/providers.dart';
import '../widgets/invalid_booru_warning_container.dart';
import '../widgets/unknown_config_booru_selector.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
  });

  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final engine = ref.watch(booruEngineProvider);
    final editId = ref.watch(editBooruConfigIdProvider);
    final notifier = ref.watch(editBooruConfigProvider(editId).notifier);

    final config = ref
        .watch(initialBooruConfigProvider)
        .copyWith(
          booruIdHint: engine?.id,
        );
    final unknownBooruWidgetsBuilder = ref
        .watch(booruBuilderProvider(config.auth))
        ?.unknownBooruWidgetsBuilder;

    ref.listen(booruEngineProvider, (previous, next) {
      if (previous != next) {
        // reset the config when the engine changes
        notifier.updateLoginAndApiKey('', '');
      }
    });

    return Material(
      color: backgroundColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.viewPaddingOf(context).top,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    context.t.booru.unknown_engine_selection_request,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                  indent: 16,
                ),
                const InvalidBooruWarningContainer(),
                const UnknownConfigBooruSelector(),
                if (unknownBooruWidgetsBuilder != null)
                  unknownBooruWidgetsBuilder(context)
                else
                  const UnknownBooruWidgetsBuilder(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top,
            right: 8,
            child: IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Symbols.close),
            ),
          ),
        ],
      ),
    );
  }
}
