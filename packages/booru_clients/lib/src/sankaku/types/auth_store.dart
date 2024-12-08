// Dart imports:
import 'dart:convert';

// Project imports:
import 'token.dart';

abstract interface class AuthStore {
  Future<void> saveToken(Token token);
  Future<Token?> getToken();
}

class AuthStoreBuilder {
  AuthStoreBuilder({
    required this.save,
    required this.load,
  });

  final void Function(String token) save;
  final Future<String> Function() load;

  Future<void> saveToken(Token token) async {
    final json = jsonEncode(token.toJson());
    save(json);
  }

  Future<Token?> loadToken() async {
    final json = await load();
    if (json.isEmpty) return null;
    final data = jsonDecode(json);

    return Token.fromJson(data);
  }
}

class InMemoryAuthStore implements AuthStore {
  Token? _token;

  @override
  Future<Token?> getToken() async {
    return _token;
  }

  @override
  Future<void> saveToken(Token token) async {
    _token = token;
  }
}
