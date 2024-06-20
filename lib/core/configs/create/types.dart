// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';

class AuthConfigData extends Equatable {
  const AuthConfigData({
    required this.login,
    required this.apiKey,
    required this.passHash,
  });

  AuthConfigData.fromConfig(BooruConfigData config)
      : login = config.login,
        apiKey = config.apiKey,
        passHash = config.passHash;

  final String login;
  final String apiKey;
  final String? passHash;

  AuthConfigData copyWith({
    String? login,
    String? apiKey,
    String? Function()? passHash,
  }) {
    return AuthConfigData(
      login: login ?? this.login,
      apiKey: apiKey ?? this.apiKey,
      passHash: passHash != null ? passHash() : this.passHash,
    );
  }

  @override
  List<Object?> get props => [
        login,
        apiKey,
        passHash,
      ];
}

extension AuthConfigDataX on AuthConfigData {
  bool get isEmpty => login.isEmpty && apiKey.isEmpty;

  bool get isValid => isEmpty || (login.isNotEmpty && apiKey.isNotEmpty);
}
