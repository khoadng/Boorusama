enum SearchBarScrollBehavior {
  autoHide,
  persistent;

  factory SearchBarScrollBehavior.parse(dynamic value) => switch (value) {
    'autoHide' || '0' || 0 => autoHide,
    'persistent' || '1' || 1 => persistent,
    _ => defaultValue,
  };

  static const SearchBarScrollBehavior defaultValue = autoHide;

  bool get persistSearchBar => this == persistent;

  dynamic toData() => index;
}
