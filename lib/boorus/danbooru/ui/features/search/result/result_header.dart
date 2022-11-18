// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'result_counter.dart';

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: ResultCounter(),
          ),
        ],
      ),
    );
  }
}
