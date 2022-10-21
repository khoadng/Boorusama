// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/wiki/wiki_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_other_names.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({
    Key? key,
    required this.characterName,
    required this.backgroundImageUrl,
  }) : super(key: key);

  final String characterName;
  final String backgroundImageUrl;

  @override
  Widget build(BuildContext context) {
    return TagDetailPage(
      tagName: characterName,
      otherNamesBuilder: (context) => BlocBuilder<WikiBloc, WikiState>(
        builder: (context, state) => ConditionalRenderWidget(
          condition: state.wiki != null,
          childBuilder: (context) =>
              TagOtherNames(otherNames: state.wiki!.otherNames),
        ),
      ),
      backgroundImageUrl: backgroundImageUrl,
    );
  }
}
