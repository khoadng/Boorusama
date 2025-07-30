// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/iap/iap.dart';
import 'premium_providers.dart';

enum LayoutPreviewStatus {
  off,
  on,
}

const kPreviewDuration = Duration(minutes: 10);

class LayoutPreviewState extends Equatable {
  const LayoutPreviewState({
    required this.status,
    this.expiresAt,
    Timer? timer,
    this.remaining,
  }) : _timer = timer;

  const LayoutPreviewState.off()
    : this(
        status: LayoutPreviewStatus.off,
        expiresAt: null,
        timer: null,
      );

  final LayoutPreviewStatus status;
  final DateTime? expiresAt;
  final Timer? _timer;
  final Duration? remaining;

  LayoutPreviewState copyWith({
    LayoutPreviewStatus? status,
    Duration? remaining,
  }) {
    return LayoutPreviewState(
      status: status ?? this.status,
      expiresAt: expiresAt,
      timer: _timer,
      remaining: remaining ?? this.remaining,
    );
  }

  @override
  List<Object?> get props => [
    status,
    expiresAt,
    _timer,
    remaining,
  ];
}

final hasPremiumLayoutProvider = Provider<bool>((ref) {
  final previewState = ref.watch(premiumLayoutPreviewProvider);
  if (previewState.status == LayoutPreviewStatus.on) {
    return true;
  }
  return ref.watch(hasPremiumProvider);
});

final premiumLayoutPreviewProvider =
    NotifierProvider<PremiumLayoutPreviewNotifier, LayoutPreviewState>(
      PremiumLayoutPreviewNotifier.new,
    );

class PremiumLayoutPreviewNotifier extends Notifier<LayoutPreviewState> {
  @override
  LayoutPreviewState build() {
    ref
      ..onDispose(() {
        _cancelTimer();
      })
      // listen to purchase changes and cancel timer if needed
      ..listen(
        subscriptionNotifierProvider,
        (previous, next) {
          if (next.valueOrNull != null) {
            disable();
          }
        },
      );

    return const LayoutPreviewState.off();
  }

  void enable() {
    final expiresAt = DateTime.now().add(kPreviewDuration);

    // Immediately update state with initial remaining time
    final initialRemaining = expiresAt.difference(DateTime.now());

    state = LayoutPreviewState(
      status: LayoutPreviewStatus.on,
      expiresAt: expiresAt,
      timer: Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          final remaining = expiresAt.difference(DateTime.now());
          if (remaining.isNegative) {
            disable();
          } else {
            state = state.copyWith(remaining: remaining);
          }
        },
      ),
      remaining: initialRemaining,
    );
  }

  void disable() {
    _cancelTimer();

    state = const LayoutPreviewState.off();
  }

  void _cancelTimer() {
    if (state._timer case final timer?) {
      timer.cancel();
    }
  }
}
