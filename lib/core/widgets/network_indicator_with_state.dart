// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/networking.dart';
import 'network_unavailable_indicator.dart';

class NetworkUnavailableIndicatorWithState extends ConsumerWidget {
  const NetworkUnavailableIndicatorWithState({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkStateProvider);

    return switch (state) {
      NetworkDisconnectedState _ => const NetworkUnavailableIndicator(),
      _ => const SizedBox.shrink(),
    };
  }
}

class NetworkUnavailableRemovePadding extends ConsumerWidget {
  const NetworkUnavailableRemovePadding({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNetworkUnavailable = ref.watch(
      networkStateProvider.select((state) => state is NetworkDisconnectedState),
    );

    return isNetworkUnavailable
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          )
        : child;
  }
}
