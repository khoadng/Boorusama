// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infra/local/repositories/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_search_page.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search_history/search_history.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/application/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/searches/searches.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/domain/tags/tags.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'ui/gelbooru_post_detail_page.dart';

void goToGelbooruPostDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialIndex,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => BlocSelector<SettingsCubit, SettingsState, Settings>(
      selector: (state) => state.settings,
      builder: (_, settings) {
        return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return GelbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (gcontext) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: gcontext.read<ThemeBloc>()),
                  BlocProvider(create: (_) => SliverPostGridBloc()),
                  BlocProvider(
                    create: (_) => TagBloc(
                      tagRepository: gcontext.read<TagRepository>(),
                    ),
                  ),
                ],
                child: GelbooruPostDetailPage(
                  posts: posts,
                  initialIndex: initialIndex,
                ),
              ),
            );
          },
        );
      },
    ),
  ));
}

void goToGelbooruSearchPage(
  BuildContext context, {
  String? tag,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (_, sstate) {
          return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
            builder: (_, state) {
              return GelbooruProvider.of(
                context,
                booru: state.booru!,
                builder: (gcontext) {
                  final tagInfo = gcontext.read<TagInfo>();
                  final searchHistoryCubit = SearchHistoryBloc(
                    searchHistoryRepository:
                        gcontext.read<SearchHistoryRepository>(),
                  )..add(const SearchHistoryFetched());
                  final favoriteTagBloc = FavoriteTagBloc(
                    favoriteTagRepository:
                        gcontext.read<FavoriteTagRepository>(),
                  );

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: searchHistoryCubit),
                      BlocProvider.value(value: favoriteTagBloc),
                    ],
                    child: GelbooruSearchPage(
                      autoFocusSearchBar: sstate.settings.autoFocusSearchBar,
                      metatags: tagInfo.metatags,
                      metatagHighlightColor:
                          Theme.of(context).colorScheme.primary,
                      userMetatagRepository:
                          gcontext.read<UserMetatagRepository>(),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    },
  ));
}
