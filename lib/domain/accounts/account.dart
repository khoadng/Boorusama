class Account {
  String _username;
  String _apiKey;
  int _id;

  Account(this._username, this._apiKey, this._id);

  String get username => _username;
  String get apiKey => _apiKey;
  int get id => _id;

  factory Account.create(String username, String apiKey, int id) {
    return Account(username, apiKey, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': _username,
      'apiKey': _apiKey,
      'id': _id,
    };
  }

  @override
  String toString() {
    return "$username ($id)";
  }
}
