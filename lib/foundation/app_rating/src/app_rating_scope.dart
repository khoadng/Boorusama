// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'providers.dart';

class AppRatingScope extends ConsumerWidget {
  const AppRatingScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(appRatingProvider);

    return service?.createRatingWidget(child: child) ?? child;
  }
}
