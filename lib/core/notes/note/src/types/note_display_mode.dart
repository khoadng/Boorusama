enum NoteDisplayMode {
  box,
  inlineHorizontal,
  inlineVertical;

  factory NoteDisplayMode.parse(dynamic value) => switch (value) {
    'box' || '0' || 0 => box,
    'inlineHorizontal' || '1' || 1 => inlineHorizontal,
    'inlineVertical' || '2' || 2 => inlineVertical,
    _ => defaultValue,
  };

  static const NoteDisplayMode defaultValue = box;

  dynamic toData() => index;
}
