// Flutter imports:
import 'package:flutter/material.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized'),
      ),
      body: const Center(
        child: Text('You must be logged in to view this page'),
      ),
    );
  }
}
