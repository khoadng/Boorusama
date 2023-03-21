// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'related_tag_header.dart';

class RelatedTagSection extends StatelessWidget {
  const RelatedTagSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final status = context.select((RelatedTagBloc bloc) => bloc.state.status);

    switch (status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const TagChipsPlaceholder();
      case LoadStatus.success:
        return BlocBuilder<RelatedTagBloc, AsyncLoadState<RelatedTag>>(
          builder: (context, state) => ConditionalRenderWidget(
            condition: state.data != null && state.data!.tags.isNotEmpty,
            childBuilder: (context) => RelatedTagHeader(
              relatedTag: state.data!,
            ),
          ),
        );
      case LoadStatus.failure:
        return const SizedBox.shrink();
    }
  }
}
