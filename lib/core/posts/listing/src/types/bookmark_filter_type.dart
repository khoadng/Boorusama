enum BookmarkFilterType {
  none,
  hideAll;

  factory BookmarkFilterType.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'hideAll' || '1' || 1 => hideAll,
    _ => defaultValue,
  };

  static const BookmarkFilterType defaultValue = none;

  bool get shouldFilterBookmarks => this != none;

  dynamic toData() => index;
}
