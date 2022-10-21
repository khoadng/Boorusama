// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artist/artist.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_other_names.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';

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
    return TagDetailPage(
      tagName: artistName,
      otherNamesBuilder: (context) => BlocBuilder<ArtistBloc, ArtistState>(
        builder: (context, state) => ConditionalRenderWidget(
          condition: state.status == LoadStatus.success,
          childBuilder: (context) =>
              TagOtherNames(otherNames: state.artist.otherNames),
        ),
      ),
      backgroundImageUrl: backgroundImageUrl,
    );
  }
}
