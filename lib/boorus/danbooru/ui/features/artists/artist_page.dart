// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page_desktop.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_other_names.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/core.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({
    super.key,
    required this.artistName,
    required this.backgroundImageUrl,
  });

  final String artistName;
  final String backgroundImageUrl;

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
