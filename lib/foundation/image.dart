mixin ImageInfoMixin {
  double get width;
  double get height;

  double get aspectRatio => height != 0 ? width / height : 0;
}
