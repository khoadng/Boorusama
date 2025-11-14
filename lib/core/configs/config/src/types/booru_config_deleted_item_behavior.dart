enum BooruConfigDeletedItemBehavior {
  show,
  hide;

  factory BooruConfigDeletedItemBehavior.parse(dynamic value) =>
      switch (value) {
        0 || '0' || 'show' => show,
        1 || '1' || 'hide' => hide,
        _ => defaultValue,
      };

  static const BooruConfigDeletedItemBehavior defaultValue = show;

  bool get isHidden => this == hide;
}
