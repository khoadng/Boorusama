// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'result_counter.dart';

class ResultHeader extends StatelessWidget {
  const ResultHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.select((SearchBloc bloc) => bloc.state.totalResults);

    if (count == null) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: Row(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: ResultCounter(),
          ),
        ],
      ),
    );
  }
}
