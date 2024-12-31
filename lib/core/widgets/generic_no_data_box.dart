// Flutter imports:
import 'package:flutter/material.dart';

class GenericNoDataBox extends StatelessWidget {
  const GenericNoDataBox({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
