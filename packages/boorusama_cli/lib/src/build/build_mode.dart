enum BuildMode {
  release,
  debug,
  profile
  ;

  String get flag => '--$name';
}
