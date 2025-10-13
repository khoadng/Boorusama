// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/home/types.dart';
import '../favorites/widgets.dart';
import '../popular/widgets.dart';

final ke621AltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const E621FavoritesPage(),
  ),
  const CustomHomeViewKey('popular'): CustomHomeDataBuilder(
    displayName: (context) => context.t.explore.popular,
    builder: (context, _) => const E621PopularPage(),
  ),
};
