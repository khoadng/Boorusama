enum ScreenSize {
  small,
  medium,
  large,
}

ScreenSize screenWidthToDisplaySize(double width) {
  if (width < 600) return ScreenSize.small;
  if (width > 600 && width <= 1000) return ScreenSize.medium;
  return ScreenSize.large;
}
