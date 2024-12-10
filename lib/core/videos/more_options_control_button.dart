// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../widgets/mobile_config_tile.dart';
import '../foundation/display.dart';

class MoreOptionsControlButton extends StatelessWidget {
  const MoreOptionsControlButton({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
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
    super.key,
    required this.value,
    required this.onChanged,
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
    super.key,
    required this.onChanged,
    required this.speeds,
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
