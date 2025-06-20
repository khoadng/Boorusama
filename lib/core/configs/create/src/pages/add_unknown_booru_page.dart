// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../boorus/booru/booru.dart';
import '../../../auth/widgets.dart';
import '../../widgets.dart';
import '../providers/internal_providers.dart';
import '../widgets/booru_url_field.dart';
import '../widgets/invalid_booru_warning_container.dart';
import '../widgets/unknown_booru_submit_button.dart';
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
    final engine = ref.watch(booruEngineProvider);
    final theme = Theme.of(context);

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
                    'Select a booru engine to continue',
                    style: theme.textTheme.headlineSmall!
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                  indent: 16,
                ),
                const InvalidBooruWarningContainer(),
                const UnknownConfigBooruSelector(),
                const BooruConfigNameField(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BooruUrlField(),
                      if (engine != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (engine != BooruType.hydrus)
                        Text(
                          'Advanced options (optional)',
                          style: theme.textTheme.titleMedium,
                        ),
                      if (engine != BooruType.hydrus)
                        const DefaultBooruInstructionText(
                          '*These options only be used if the site allows it.',
                        ),
                      //FIXME: make this part of the config customisable
                      if (engine != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (engine != BooruType.hydrus)
                        const DefaultBooruLoginField(),
                      const SizedBox(height: 16),
                      const DefaultBooruApiKeyField(),
                      const SizedBox(height: 16),
                      const UnknownBooruSubmitButton(),
                    ],
                  ),
                ),
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
