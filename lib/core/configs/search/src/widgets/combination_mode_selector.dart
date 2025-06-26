// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../../../create/providers.dart';
import '../providers/blacklist_configs_notifier.dart';
import '../types/blacklist_combination_mode.dart';

class CombinationModeSelector extends ConsumerWidget {
  const CombinationModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          showBooruModalBottomSheet(
            context: context,
            builder: (context) => ProviderScope(
              overrides: [
                editBooruConfigIdProvider.overrideWithValue(id),
              ],
              child: const CombinationModeSheet(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          child: Row(
            children: [
              Text(
                selectedMode.name,
              ),
              Icon(
                Symbols.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CombinationModeSheet extends ConsumerWidget {
  const CombinationModeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Text(
            'Combination Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...kBlacklistCombinationModes.map(
          (e) => CombinationModeOptionTile(
            selected: selectedMode == e,
            title: e.name,
            subtitle: e.description,
            onTap: () {
              ref.read(blacklistConfigsProvider(id).notifier).changeMode(e);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

class CombinationModeOptionTile extends StatelessWidget {
  const CombinationModeOptionTile({
    required this.title,
    required this.subtitle,
    super.key,
    this.selected = false,
    this.onTap,
  });

  final bool selected;
  final void Function()? onTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.all(12 + (selected ? 0 : 1.5)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(
              width: selected ? 1.5 : 0.25,
              color:
                  selected ? colorScheme.onSurface : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
