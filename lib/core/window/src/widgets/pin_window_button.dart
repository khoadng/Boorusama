// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../foundation/animations/constants.dart';
import '../../../themes/theme/types.dart';
import '../../../widgets/hover_aware_container.dart';
import '../providers/always_on_top_provider.dart';

class PinWindowButton extends ConsumerWidget {
  const PinWindowButton({
    super.key,
    this.iconSize = 16,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alwaysOnTop = ref.watch(alwaysOnTopProvider);

    ref.listen(
      alwaysOnTopProvider,
      (prev, next) {
        next.whenData((isPinned) {
          final message = isPinned
              ? context.t.window.pin.pin_toast
              : context.t.window.pin.unpin_toast;
          showToast(
            message,
            position: ToastPosition.top,
            textPadding: const EdgeInsets.all(8),
            duration: AppDurations.shortToast,
          );
        });
      },
    );

    return alwaysOnTop.maybeWhen(
      data: (isPinned) => GestureDetector(
        onTap: () {
          ref.read(alwaysOnTopProvider.notifier).toggle();
        },
        child: HoverAwareContainer(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: iconSize,
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
