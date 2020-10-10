class Account {
  String _username;
  String _apiKey;

  Account(this._username, this._apiKey);

  String get username => _username;
  String get apiKey => _apiKey;

  factory Account.create(String username, String apiKey) {
    return Account(username, apiKey);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': _username,
      'apiKey': _apiKey,
    };
  }
}
