// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../foundation/display.dart';
import '../../widgets/widgets.dart';

class UnimplementedPage extends StatelessWidget {
  const UnimplementedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Page not implemented yet'),
      ),
    );
  }
}

class LargeScreenAwareInvalidPage extends StatelessWidget {
  const LargeScreenAwareInvalidPage({
    required this.message,
    super.key,
    this.useDialog = true,
  });

  final String message;
  final bool useDialog;

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;
    final page = InvalidPage(message: message);

    return isLarge && useDialog ? BooruDialog(child: page) : page;
  }
}

class InvalidPage extends StatelessWidget {
  const InvalidPage({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
