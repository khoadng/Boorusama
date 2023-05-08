// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page_desktop.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/tag_other_names.dart';

Widget provideArtistPageDependencies(
  BuildContext context, {
  required String artist,
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
                value: dcontext.read<ArtistBloc>()
                  ..add(ArtistFetched(name: artist)),
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

class DanbooruArtistPage extends StatelessWidget {
  const DanbooruArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return provideArtistPageDependencies(
      context,
      artist: tag,
      page: DanbooruArtistPage(
        artistName: tag,
        backgroundImageUrl: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? TagDetailPage(
            tagName: artistName,
            otherNamesBuilder: (context) =>
                BlocBuilder<ArtistBloc, ArtistState>(builder: (context, state) {
              switch (state.status) {
                case LoadStatus.initial:
                case LoadStatus.loading:
                  return const SizedBox(height: 40, width: 40);
                case LoadStatus.success:
                  return TagOtherNames(otherNames: state.artist.otherNames);
                case LoadStatus.failure:
                  return const SizedBox.shrink();
              }
            }),
            backgroundImageUrl: backgroundImageUrl,
          )
        : TagDetailPageDesktop(
            tagName: artistName,
            otherNamesBuilder: (context) =>
                BlocBuilder<ArtistBloc, ArtistState>(builder: (context, state) {
              switch (state.status) {
                case LoadStatus.initial:
                case LoadStatus.loading:
                  return const SizedBox(height: 40, width: 40);
                case LoadStatus.success:
                  return TagOtherNames(otherNames: state.artist.otherNames);
                case LoadStatus.failure:
                  return const SizedBox.shrink();
              }
            }),
          );
  }
}
