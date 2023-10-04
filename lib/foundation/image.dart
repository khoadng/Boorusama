mixin ImageInfoMixin {
  double get width;
  double get height;

  double? get aspectRatio => width <= 0 || height <= 0 ? null : width / height;
}
