// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../foundation/display.dart';
import '../widgets/mobile_config_tile.dart';

class MoreOptionsControlButton extends StatelessWidget {
  const MoreOptionsControlButton({
    required this.speed,
    required this.onSpeedChanged,
    super.key,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showMaterialModalBottomSheet(
          context: context,
          builder: (_) => BooruVideoOptionSheet(
            value: speed,
            onChanged: onSpeedChanged,
          ),
        ),
        child: const Icon(
          Symbols.settings,
          fill: 1,
        ),
      ),
    );
  }
}

class BooruVideoOptionSheet extends StatelessWidget {
  const BooruVideoOptionSheet({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final void Function(double value) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: kPreferredLayout.isDesktop
          ? colorScheme.surface
          : colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            MobileConfigTile(
              value: _buildSpeedText(value),
              title: 'Play back speed',
              onTap: () {
                Navigator.of(context).pop();
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (_) => PlaybackSpeedActionSheet(
                    onChanged: onChanged,
                    speeds: const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
                  ),
                );
              },
            ),
            SizedBox(
              height: MediaQuery.viewPaddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}

class PlaybackSpeedActionSheet extends StatelessWidget {
  const PlaybackSpeedActionSheet({
    required this.onChanged,
    required this.speeds,
    super.key,
  });

  final void Function(double value) onChanged;
  final List<double> speeds;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (e) => ListTile(
                  title: Text(_buildSpeedText(e)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onChanged(e);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

String _buildSpeedText(double speed) {
  if (speed == 1.0) return 'Normal';

  final speedText = speed.toStringAsFixed(2);
  // if end with zero, remove it
  final cleanned = speedText.endsWith('0')
      ? speedText.substring(0, speedText.length - 1)
      : speedText;

  return '${cleanned}x';
}

class MobilePostGridConfigTile extends StatelessWidget {
  const MobilePostGridConfigTile({
    required this.value,
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14,
              ),
            ),
            const Icon(Symbols.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class OptionActionSheet<T> extends StatelessWidget {
  const OptionActionSheet({
    required this.onChanged,
    required this.options,
    required this.optionName,
    super.key,
  });

  final void Function(T option) onChanged;
  final List<T> options;
  final String Function(T option) optionName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...options.map(
              (e) => ListTile(
                title: Text(optionName(e)),
                onTap: () {
                  Navigator.of(context).pop();
                  onChanged(e);
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.viewPaddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}
