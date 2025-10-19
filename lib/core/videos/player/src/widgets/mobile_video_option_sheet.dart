// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../posts/post/types.dart';
import '../types/utils.dart';
import 'mobile_video_option_tile.dart';

class MobileVideoOptionSheet extends ConsumerWidget {
  const MobileVideoOptionSheet({
    required this.value,
    required this.onSpeedChanged,
    required this.onLock,
    required this.onOpenSettings,
    required this.post,
    super.key,
  });

  final double value;
  final void Function() onSpeedChanged;
  final void Function() onLock;
  final void Function() onOpenSettings;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (booruBuilder?.videoQualitySelectionBuilder case final builder?)
          ?builder(context, post),
        MobileConfigTile(
          value: buildSpeedText(value, context),
          title: context.t.video_player.playback_speed,
          onTap: onSpeedChanged,
        ),
        ListTile(
          title: Text(context.t.video_player.lock_screen),
          onTap: onLock,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onOpenSettings,
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
    );
  }
}

class PlaybackSpeedActionSheet extends StatelessWidget {
  const PlaybackSpeedActionSheet({
    required this.onChanged,

    super.key,
  });

  final void Function(double value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: kSpeedOptions
            .map(
              (e) => ListTile(
                title: Text(buildSpeedText(e, context)),
                onTap: () {
                  Navigator.of(context).pop();
                  onChanged(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
