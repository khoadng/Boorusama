// Project imports:
import 'package:boorusama/core/boorus/boorus.dart';

String? booruFilterConfigToGelbooruTag(BooruConfigRatingFilter? filter) =>
    switch (filter) {
      BooruConfigRatingFilter.none || null => null,
      BooruConfigRatingFilter.hideExplicit => '-rating:explicit',
      BooruConfigRatingFilter.hideNSFW => 'rating:general',
    };
