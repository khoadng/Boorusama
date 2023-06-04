// Flutter imports:
import 'package:flutter/material.dart';

class ResultCounter extends StatelessWidget {
  const ResultCounter({
    super.key,
    required this.count,
    required this.loading,
  });

  final bool loading;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Row(
        children: [
          Text(
            'Searching...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator.adaptive(),
          ),
        ],
      );
    }

    if (count > 0) {
      return Text(
        '$count Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    } else {
      return Text(
        'No Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
  }
}
