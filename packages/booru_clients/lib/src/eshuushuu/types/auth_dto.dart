class AuthResponseDto {
  AuthResponseDto({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
  });

  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.userId,
    this.refreshTokenExpiry,
  });

  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
  final int? userId;
  final DateTime? refreshTokenExpiry;
}
