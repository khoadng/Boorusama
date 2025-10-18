// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../foundation/animations/constants.dart';
import '../../../themes/theme/types.dart';
import '../providers/always_on_top_provider.dart';

class PinWindowButton extends ConsumerStatefulWidget {
  const PinWindowButton({
    super.key,
    this.iconSize = 16,
  });

  final double iconSize;

  @override
  ConsumerState<PinWindowButton> createState() => _PinWindowButtonState();
}

class _PinWindowButtonState extends ConsumerState<PinWindowButton> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
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

    return alwaysOnTop.when(
      data: (isPinned) => GestureDetector(
        onTap: () {
          ref.read(alwaysOnTopProvider.notifier).toggle();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: _PinContainer(
            iconSize: widget.iconSize,
            isHovered: _isHovered,
            child: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: widget.iconSize,
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
        ),
      ),
      loading: () => const _PinContainer(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
    );
  }
}

class _PinContainer extends StatelessWidget {
  const _PinContainer({
    this.iconSize = 16,
    this.isHovered = false,
    required this.child,
  });

  final Widget child;
  final double iconSize;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isHovered
            ? Theme.of(context).colorScheme.surfaceContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: child,
        ),
      ),
    );
  }
}
