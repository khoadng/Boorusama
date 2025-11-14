enum BooruConfigBannedPostVisibility {
  show,
  hide;

  factory BooruConfigBannedPostVisibility.parse(dynamic value) =>
      switch (value) {
        0 || '0' || 'show' => show,
        1 || '1' || 'hide' => hide,
        _ => defaultValue,
      };

  static const BooruConfigBannedPostVisibility defaultValue = show;

  bool get isHidden => this == hide;
}
