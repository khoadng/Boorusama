// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final allowSearch =
        context.select((SearchBloc bloc) => bloc.state.allowSearch);

    return ConditionalRenderWidget(
      condition: allowSearch,
      childBuilder: (context) => BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              context.read<SearchBloc>().add(const SearchRequested());
              context.read<PostCountCubit>().getPostCount(
                  state.selectedTags.map((e) => e.toString()).toList());
            },
            heroTag: null,
            child: const Icon(Icons.search),
          );
        },
      ),
    );
  }
}
