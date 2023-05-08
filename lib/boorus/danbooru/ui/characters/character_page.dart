// Flutter imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page_desktop.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/tag_other_names.dart';

Widget provideCharacterPageDependencies(
  BuildContext context, {
  required String character,
  required Widget page,
}) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (dcontext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: dcontext.read<WikiBloc>()
                  ..add(WikiFetched(tag: character)),
              ),
            ],
            child: CustomContextMenuOverlay(
              child: page,
            ),
          );
        },
      );
    },
  );
}

class CharacterPage extends StatelessWidget {
  const CharacterPage({
    super.key,
    required this.characterName,
    required this.backgroundImageUrl,
  });

  final String characterName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return provideCharacterPageDependencies(
      context,
      character: tag,
      page: CharacterPage(
        characterName: tag,
        backgroundImageUrl: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? TagDetailPage(
            tagName: characterName,
            otherNamesBuilder: (context) =>
                BlocBuilder<WikiBloc, WikiState>(builder: (context, state) {
              switch (state.status) {
                case LoadStatus.initial:
                case LoadStatus.loading:
                  return const SizedBox(height: 40, width: 40);
                case LoadStatus.success:
                  return state.wiki != null
                      ? TagOtherNames(otherNames: state.wiki!.otherNames)
                      : const SizedBox.shrink();
                case LoadStatus.failure:
                  return const SizedBox.shrink();
              }
            }),
            backgroundImageUrl: backgroundImageUrl,
          )
        : TagDetailPageDesktop(
            tagName: characterName,
            otherNamesBuilder: (context) => BlocBuilder<WikiBloc, WikiState>(
              builder: (context, state) {
                switch (state.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const SizedBox(height: 40, width: 40);
                  case LoadStatus.success:
                    return state.wiki != null
                        ? TagOtherNames(otherNames: state.wiki!.otherNames)
                        : const SizedBox.shrink();
                  case LoadStatus.failure:
                    return const SizedBox.shrink();
                }
              },
            ),
          );
  }
}
