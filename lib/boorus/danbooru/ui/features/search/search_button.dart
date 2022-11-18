// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
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
      childBuilder: (context) => FloatingActionButton(
        onPressed: () =>
            context.read<SearchBloc>().add(const SearchRequested()),
        heroTag: null,
        child: const Icon(Icons.search),
      ),
    );
  }
}
