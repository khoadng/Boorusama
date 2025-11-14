enum BooruConfigViewerNotesFetchBehavior {
  manual,
  auto;

  static BooruConfigViewerNotesFetchBehavior? tryParse(dynamic value) =>
      switch (value) {
        0 || '0' || 'manual' => manual,
        1 || '1' || 'auto' => auto,
        _ => null,
      };

  bool get isAuto => this == auto;
}
