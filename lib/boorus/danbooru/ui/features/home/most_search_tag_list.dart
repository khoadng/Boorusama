// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/core.dart';

class MostSearchTagList extends StatelessWidget {
  const MostSearchTagList({
    super.key,
    required this.onSelected,
    required this.selected,
  });

  final void Function(Search search) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final searches =
        context.select((TrendingTagCubit cubit) => cubit.state.tags);

    if (searches == null || searches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 40,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: searches.length,
        itemBuilder: (context, index) {
          final isSelected = selected == searches[index].keyword;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              disabledColor: Theme.of(context).chipTheme.disabledColor,
              backgroundColor: Theme.of(context).chipTheme.backgroundColor,
              selectedColor: Theme.of(context).chipTheme.selectedColor,
              selected: isSelected,
              onSelected: (selected) => onSelected(searches[index]),
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.all(1),
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                width: 0.5,
                color: Theme.of(context).hintColor,
              ),
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: Text(
                  searches[index].keyword.removeUnderscoreWithSpace(),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
