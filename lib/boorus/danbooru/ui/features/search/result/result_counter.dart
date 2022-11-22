// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';

class ResultCounter extends StatelessWidget {
  const ResultCounter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.select((SearchBloc bloc) => bloc.state.totalResults);

    if (count > 0) {
      return Text(
        '$count Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    } else if (count < 0) {
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
    } else {
      return Text(
        'No Results',
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
  }
}
