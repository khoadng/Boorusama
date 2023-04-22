// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';

class DanbooruMultiSelectionActions extends StatelessWidget {
  const DanbooruMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
  });

  final List<DanbooruPost> selectedPosts;
  final void Function() endMultiSelect;

  @override
  Widget build(BuildContext context) {
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        DownloadProviderWidget(
          builder: (context, download) => IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () {
                    // ignore: prefer_foreach
                    for (final p in selectedPosts) {
                      download(p);
                    }

                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.download),
          ),
        ),
        if (authenticationState is Authenticated)
          IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () async {
                    final shouldEnd = await goToAddToFavoriteGroupSelectionPage(
                      context,
                      selectedPosts,
                    );
                    if (shouldEnd != null && shouldEnd) {
                      endMultiSelect();
                    }
                  }
                : null,
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }
}
