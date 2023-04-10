// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/core/application/common.dart';
import 'trending_tags.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final state = context.select((TrendingTagCubit cubit) => cubit.state);

    return state.status != LoadStatus.success
        ? const Center(child: CircularProgressIndicator.adaptive())
        : state.tags != null && state.tags!.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'search.trending'.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  TrendingTags(
                    onTagTap: onTagTap,
                    tags: state.tags,
                  ),
                ],
              )
            : const SizedBox.shrink();
  }
}
