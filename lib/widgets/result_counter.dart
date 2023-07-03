// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

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
            'search.search_in_progress_notice'.tr(),
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
        'search.result_counter'.plural(count),
        style: Theme.of(context).textTheme.titleLarge,
      );
    } else {
      return Text(
        'search.no_result_notice'.tr(),
        style: Theme.of(context).textTheme.titleLarge,
      );
    }
  }
}
