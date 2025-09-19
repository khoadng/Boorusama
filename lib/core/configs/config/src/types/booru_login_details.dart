abstract interface class BooruLoginDetails {
  bool hasLogin();
  bool get hasStrictSFW;
  bool get hasSoftSFW;
}

mixin UnrestrictedBooruLoginDetails {
  bool get hasStrictSFW => false;
  bool get hasSoftSFW => false;
}
