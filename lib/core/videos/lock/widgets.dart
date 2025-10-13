// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../themes/theme/types.dart';
import 'providers.dart';

const kLockIconFadeDuration = Duration(milliseconds: 300);
const kLockIconHideDelay = Duration(seconds: 2);

class VideoScreenLocker extends ConsumerStatefulWidget {
  const VideoScreenLocker({
    super.key,
    required this.onLockChanged,
    required this.child,
  });

  final Widget child;
  final void Function(bool isLocked)? onLockChanged;

  @override
  ConsumerState<VideoScreenLocker> createState() => _VideoScreenLockerState();
}

class _VideoScreenLockerState extends ConsumerState<VideoScreenLocker>
    with SingleTickerProviderStateMixin {
  Timer? _hideTimer;
  late final ValueNotifier<bool> _showUnlockIcon;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _showUnlockIcon = ValueNotifier(false);
    _animationController = AnimationController(
      duration: kLockIconFadeDuration,
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _showUnlockIcon.addListener(_onIconVisibilityChanged);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _showUnlockIcon.removeListener(_onIconVisibilityChanged);
    _showUnlockIcon.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onIconVisibilityChanged() {
    if (_showUnlockIcon.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(kLockIconHideDelay, () {
      if (mounted && ref.read(screenLockProvider)) {
        _showUnlockIcon.value = false;
      }
    });
  }

  void _onScreenTap() {
    _showUnlockIcon.value = true;
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(screenLockProvider);

    ref.listen(
      screenLockProvider,
      (_, isLocked) {
        widget.onLockChanged?.call(isLocked);
        if (isLocked) {
          _showUnlockIcon.value = true;
          _startHideTimer();
        } else {
          _hideTimer?.cancel();
          _showUnlockIcon.value = false;
        }
      },
    );

    return PopScope(
      canPop: !isLocked,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: isLocked,
            child: widget.child,
          ),
          if (isLocked)
            Positioned.fill(
              child: GestureDetector(
                onTap: _onScreenTap,
                behavior: HitTestBehavior.translucent,
                child: Container(),
              ),
            ),
          if (isLocked)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                if (_fadeAnimation.value == 0) return const SizedBox.shrink();

                return Positioned(
                  right: 20,
                  child: SafeArea(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const _UnlockIcon(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _UnlockIcon extends ConsumerWidget {
  const _UnlockIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockNotifier = ref.watch(screenLockProvider.notifier);

    return Material(
      color: context.extendedColorScheme.surfaceContainerOverlay,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => lockNotifier.unlock(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Symbols.lock_open,
            color: context.extendedColorScheme.onSurfaceContainerOverlay,
            fill: 1,
          ),
        ),
      ),
    );
  }
}
