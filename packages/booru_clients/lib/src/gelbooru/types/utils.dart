enum PaginationType {
  page,
  offset;

  static PaginationType parse(String? value) => switch (value?.toLowerCase()) {
    'page' => PaginationType.page,
    'offset' => PaginationType.offset,
    _ => PaginationType.page,
  };

  int? calculatePage({int? page, int? limit}) {
    if (page == null) return null;
    return switch (this) {
      PaginationType.page => page - 1,
      PaginationType.offset => limit != null ? (page - 1) * limit : null,
    };
  }
}

int? estimateTotalPagesFromOffset({
  required int lastPageOffset,
  required int fixedLimit,
}) {
  if (fixedLimit <= 0) return null;
  return (lastPageOffset / fixedLimit).ceil() + 1;
}
