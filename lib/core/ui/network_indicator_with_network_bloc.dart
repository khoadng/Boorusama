// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/networking.dart';
import 'widgets/conditional_parent_widget.dart';
import 'widgets/conditional_render_widget.dart';
import 'widgets/network_unavailable_indicator.dart';

class NetworkUnavailableIndicatorWithNetworkBloc extends StatelessWidget {
  const NetworkUnavailableIndicatorWithNetworkBloc({
    super.key,
    this.includeSafeArea = true,
  });

  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkBloc>().state;

    return ConditionalRenderWidget(
      condition:
          state is NetworkDisconnectedState || state is NetworkInitialState,
      childBuilder: (_) => ConditionalParentWidget(
        condition: includeSafeArea,
        conditionalBuilder: (child) => SafeArea(child: child),
        child: const NetworkUnavailableIndicator(),
      ),
    );
  }
}
