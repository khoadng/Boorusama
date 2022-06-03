// Flutter imports:

// Package imports:
import 'package:fluro/fluro.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/features/accounts/profile/profile_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';
import 'presentation/features/search/search_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final artistHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return ArtistPage(
    artistName: args[0],
    backgroundImageUrl: args[1],
  );
});

final postSearchHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return SearchPage(
    initialQuery: args[0],
  );
});

final postDetailImageHandler = Handler(handlerFunc: (
  context,
  Map<String, List<String>> params,
) {
  final args = context!.settings!.arguments as List;

  return PostImagePage(
    post: args[0],
  );
});

final userHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  // final String userId = params["id"][0];

  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context!)),
      BlocProvider.value(value: BlocProvider.of<FavoritesCubit>(context)),
    ],
    child: ProfilePage(),
  );
});

final loginHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return LoginPage();
});

final settingsHandler =
    Handler(handlerFunc: (context, Map<String, List<String>> params) {
  return SettingsPage();
});
