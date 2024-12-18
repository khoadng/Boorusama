enum ZerochanSortOrder {
  recency,
  popularity,
}

enum PictureDimension {
  large,
  huge,
  landscape,
  portrait,
  square,
}

extension ZerochanSortOrderX on ZerochanSortOrder {
  String get queryParam => switch (this) {
        ZerochanSortOrder.recency => 'id',
        ZerochanSortOrder.popularity => 'fav',
      };
}

extension PictureDimensionX on PictureDimension {
  String get queryParam => name;
}
