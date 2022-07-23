// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/tag_detail_page.dart';
import 'package:boorusama/core/presentation/widgets/conditional_render_widget.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({
    Key? key,
    required this.artistName,
    required this.backgroundImageUrl,
  }) : super(key: key);

  final String artistName;
  final String backgroundImageUrl;

  @override
  Widget build(BuildContext context) {
    return TagDetailPage(
      tagName: artistName,
      otherNamesBuilder: (context) =>
          BlocBuilder<ArtistCubit, AsyncLoadState<Artist>>(
        builder: (context, state) => ConditionalRenderWidget(
          condition: state.status == LoadStatus.success,
          childBuilder: (context) =>
              TagOtherNames(otherNames: state.data!.otherNames),
        ),
      ),
      backgroundImageUrl: backgroundImageUrl,
    );
  }
}
