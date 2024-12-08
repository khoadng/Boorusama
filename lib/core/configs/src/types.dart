enum BooruConfigDeletedItemBehavior {
  show,
  hide,
}

enum BooruConfigRatingFilter {
  none,
  hideExplicit,
  hideNSFW,
  custom,
}

enum BooruConfigBannedPostVisibility {
  show,
  hide,
}

extension BooruConfigRatingFilterX on BooruConfigRatingFilter {
  String getRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Safeish',
        BooruConfigRatingFilter.hideNSFW => 'Safe',
        BooruConfigRatingFilter.custom => 'Custom'
      };

  String getFilterRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Moderate',
        BooruConfigRatingFilter.hideNSFW => 'Aggressive',
        BooruConfigRatingFilter.custom => 'Custom'
      };
}
