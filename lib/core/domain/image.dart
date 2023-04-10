mixin ImageInfoMixin {
  double get width;
  double get height;

  double get aspectRatio => width / height;
}
