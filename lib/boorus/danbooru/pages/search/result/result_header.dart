// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/ui/result_counter.dart';

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
    required this.count,
    required this.loading,
  });
  final int count;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: ResultCounter(
              count: count,
              loading: loading,
            ),
          ),
        ],
      ),
    );
  }
}
