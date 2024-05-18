// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';

class AuthConfigData extends Equatable {
  const AuthConfigData({
    required this.login,
    required this.apiKey,
  });

  AuthConfigData.fromConfig(BooruConfigData config)
      : login = config.login,
        apiKey = config.apiKey;

  final String login;
  final String apiKey;

  AuthConfigData copyWith({
    String? login,
    String? apiKey,
  }) {
    return AuthConfigData(
      login: login ?? this.login,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object> get props => [login, apiKey];
}

extension AuthConfigDataX on AuthConfigData {
  bool get isEmpty => login.isEmpty && apiKey.isEmpty;

  bool get isValid => isEmpty || (login.isNotEmpty && apiKey.isNotEmpty);
}
