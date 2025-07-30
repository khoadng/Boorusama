// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../providers/preview_providers.dart';
import '../routes/route_utils.dart';

class PremiumLayoutPreviewDialog extends ConsumerWidget {
  const PremiumLayoutPreviewDialog({
    required this.onStartPreview,
    required this.onApplyLayout,
    required this.firstTime,
    super.key,
  });

  final void Function() onStartPreview;
  final void Function() onApplyLayout;
  final bool firstTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.status,
      ),
    );

    final previewMinutes = kPreviewDuration.inMinutes.toString();

    return BooruDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Layout Preview'.hc,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const _PreviewText(),
          const SizedBox(height: 20),
          if (status == LayoutPreviewStatus.off) ...[
            FilledButton(
              style: FilledButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                ref.read(premiumLayoutPreviewProvider.notifier).enable();
                onStartPreview();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Start $previewMinutes-minute Preview'.hc,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else if (status == LayoutPreviewStatus.on && !firstTime) ...[
            FilledButton(
              style: FilledButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                onApplyLayout();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Continue Preview & Apply'.hc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              goToPremiumPage(ref);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Upgrade'.hc,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PreviewText extends ConsumerWidget {
  const _PreviewText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.status,
      ),
    );

    final remaining = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.remaining,
      ),
    );

    // Get preview duration in minutes for UI
    final previewMinutes = kPreviewDuration.inMinutes.toString();
    final colorScheme = Theme.of(context).colorScheme;

    if (status == LayoutPreviewStatus.on && remaining != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You are currently previewing a custom layout.'.hc,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: colorScheme.hintColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Time left:'.hc,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.hintColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDurationForMedia(remaining),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Text(
        'Preview your custom layout for $previewMinutes minutes. After that, you can either upgrade to premium to keep using it or retry as many times as you want.'
            .hc,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: colorScheme.hintColor,
        ),
      );
    }
  }
}
