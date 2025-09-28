// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../settings/routes.dart';
import '../../../widgets/widgets.dart';
import '../providers/providers.dart';

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
        onTap: () => showModalBottomSheet(
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

class BooruVideoOptionSheet extends ConsumerWidget {
  const BooruVideoOptionSheet({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final void Function(double value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenLockNotifier = ref.watch(screenLockProvider.notifier);

    return Material(
      color: kPreferredLayout.isDesktop
          ? colorScheme.surface
          : colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MobileConfigTile(
              value: _buildSpeedText(value, context),
              title: context.t.video_player.playback_speed,
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  builder: (_) => PlaybackSpeedActionSheet(
                    onChanged: onChanged,
                    speeds: const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
                  ),
                );
              },
            ),
            ListTile(
              title: Text(context.t.video_player.lock_screen),
              onTap: () {
                Navigator.of(context).pop();
                screenLockNotifier.lock();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        openImageViewerSettingsPage(ref);
                      },
                      child: Text(context.t.generic.action.more),
                    ),
                  ),
                ],
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
                  title: Text(_buildSpeedText(e, context)),
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

String _buildSpeedText(double speed, BuildContext context) {
  if (speed == 1.0) return context.t.video_player.speed.normal;

  final speedText = speed.toStringAsFixed(2);
  // if end with zero, remove it
  final cleanned = speedText.endsWith('0')
      ? speedText.substring(0, speedText.length - 1)
      : speedText;

  return '${cleanned}x';
}
