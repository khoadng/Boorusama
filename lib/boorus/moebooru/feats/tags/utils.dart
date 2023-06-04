// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';

String? booruFilterConfigToMoebooruTag(BooruConfigRatingFilter? filter) =>
    switch (filter) {
      BooruConfigRatingFilter.none || null => null,
      BooruConfigRatingFilter.hideExplicit => '-rating:e',
      BooruConfigRatingFilter.hideNSFW => 'rating:s'
    };
