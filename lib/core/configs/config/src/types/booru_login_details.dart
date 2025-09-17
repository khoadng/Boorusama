abstract interface class BooruLoginDetails {
  bool hasLogin();
  bool get hasStrictSFW;
  bool get hasSoftSFW;
}

class DefaultBooruLoginDetails implements BooruLoginDetails {
  const DefaultBooruLoginDetails({
    required this.login,
    required this.apiKey,
    required this.url,
  });

  final String? login;
  final String? apiKey;
  final String url;

  @override
  bool hasLogin() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }

  @override
  bool get hasStrictSFW => false;

  @override
  bool get hasSoftSFW => false;
}
