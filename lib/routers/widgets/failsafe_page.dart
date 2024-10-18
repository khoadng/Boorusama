// Flutter imports:
import 'package:flutter/material.dart';

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

class InvalidPage extends StatelessWidget {
  const InvalidPage({super.key, required this.message});

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
