import 'package:flutter/material.dart';

class KurumiRemoveLeftPaddingOnLargeScreen extends StatelessWidget {
  const KurumiRemoveLeftPaddingOnLargeScreen({
    required this.child,
    required this.isLargeScreen,
    super.key,
  });

  final Widget child;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeLeft: isLargeScreen,
      child: child,
    );
  }
}
