// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/widgets/widgets.dart';

class NetworkUnavailableIndicatorWithState extends ConsumerWidget {
  const NetworkUnavailableIndicatorWithState({
    super.key,
    this.includeSafeArea = false,
  });

  final bool includeSafeArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkStateProvider);

    return switch (state) {
      NetworkDisconnectedState _ => ConditionalParentWidget(
          condition: includeSafeArea,
          conditionalBuilder: (child) => SafeArea(child: child),
          child: const NetworkUnavailableIndicator(),
        ),
      NetworkInitialState _ => const SizedBox.shrink(),
      NetworkLoadingState _ => ConditionalParentWidget(
          condition: includeSafeArea,
          conditionalBuilder: (child) => SafeArea(child: child),
          child: const NetworkConnectingIndicator(),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
