// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/home/types.dart';
import '../favorites/widgets.dart';
import '../popular/widgets.dart';

final kMoebooruAltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const MoebooruFavoritesPage(),
  ),
  const CustomHomeViewKey('popular'): CustomHomeDataBuilder(
    displayName: (context) => context.t.explore.popular,
    builder: (context, _) => const MoebooruPopularPage(),
  ),
  const CustomHomeViewKey('hot'): CustomHomeDataBuilder(
    displayName: (context) => context.t.explore.hot,
    builder: (context, _) => const MoebooruPopularRecentPage(),
  ),
};
